import { CalendarDateViewModel, CalendarMonthEntity } from './viewmodel/CalendarEntity'
import { LazyDataSource, ObservableArray } from './viewmodel/LazyDataSource'
import promptAction from '@ohos.promptAction'
import { RangeDateStrategy } from './strategy/RangeDateStrategy'
import { DayPickerStrategy } from './strategy/DayPickerStrategy'
import { BaseCalendarStrategy } from './strategy/ICalendarStrategy'
import { FixDayStrategy } from './strategy/FixDayStrategy'

@Component
@Entry
struct CalendarPage {
  @State weekDays: string[] = ["日", "一", "二", "三", "四", "五", "六"]
  private strategyList = [new RangeDateStrategy(), new DayPickerStrategy(), new FixDayStrategy(3)]
  private currentStrategy: BaseCalendarStrategy = this.strategyList[0]
  @State readonly monthList: CalendarMonthEntity[] = []

  aboutToAppear() {
    this.changePosition(0)
  }

  i=0
  changePosition(selectPos: number) {
    if (this.currentStrategy != null) {
      console.log(`清空之前模式：${this.currentStrategy.constructor.name}`);
      this.currentStrategy.reset()
    }
    if (selectPos < 0 || selectPos >= this.strategyList.length) {
      promptAction.showToast({ message: "超出可选模式范围" })
      return
    }
    this.currentStrategy = this.strategyList[selectPos]
    promptAction.showToast({ message: `当前模式：${this.currentStrategy.constructor.name}` })
    this.logDateData()
    this.monthList.splice(0)
    this.i++
    this.monthList.push(this.currentStrategy.getMonthList()[this.i])
  }

  logDateData() {
    let logData: CalendarMonthEntity = this.currentStrategy.getMonthList()[1]
    console.log(`当前${logData.title}数据 ：`);
    logData.dateList.forEach(date => {
      console.log(`${date.date}(start = ${date.isStart},end = ${date.isEnd},duration = ${date.isDuration})`);
    })
  }

  build() {
    Stack() {
      Column() {
        this.TopBanner()
        this.WeekDayView()
        CalendarScroll({ monthList: this.monthList, event: (dateItem) => {
          promptAction.showToast({ message: "time:" + dateItem.timeStamp })
          if (this.currentStrategy == null) {
            return
          }
          console.log(`当前模式：${this.currentStrategy.constructor.name}`);
          this.currentStrategy.choose(dateItem)
        } }).height(300)
      }.height("100%")

      this.ChooseType()
    }.align(Alignment.Bottom)
  }

  @Builder
  TopBanner() {
    Row() {
      Blank().layoutWeight(1)
      Text("清空")
        .padding(10)
        .onClick(() => {
          console.log(`当前模式：${this.currentStrategy.constructor.name}`);
          this.currentStrategy.reset()
          this.logDateData()
        }).align(Alignment.End)
    }
  }

  @Builder
  WeekDayView() {
    GridRow({ columns: 7 }) {
      ForEach(this.weekDays, day => {
        GridCol() {
          Text(day)
        }
      })
    }
  }

  @Builder
  ChooseType() {
    Button("改变策略模式").margin(20).bindMenu([
      {
        value: '选择正常模式',
        action: () => {
          this.changePosition(0)
        }
      },
      {
        value: '选择单天模式',
        action: () => {
          this.changePosition(1)
        }
      },
      {
        value: '选择固定天数模式',
        action: () => {
          this.changePosition(2)
        }
      },
      {
        value: '选择续租模式',
        action: () => {
          this.changePosition(3)
        }
      }
    ])
  }
}

@Component
export struct CalendarScroll {
  @Link private monthList: CalendarMonthEntity[]
  private scroller: Scroller = new Scroller()
  private event: (date: CalendarDateViewModel) => void = (e) => {
  }

  build() {
    Column({}) {
      List({
        scroller: this.scroller
      }) {
        LazyForEach(new LazyDataSource(this.monthList), (month: CalendarMonthEntity) => {
          ListItem() {
            CalendarMonth({ monthEntity: month, event: dateItem => {
              this.event.call(this.event, dateItem)
            } })
          }
        },(item:CalendarMonthEntity)=>item.title)
      }
    }
  }
}

@Preview
@Component
struct CalendarMonth {
  @ObjectLink private monthEntity: CalendarMonthEntity
  private event: (date: CalendarDateViewModel) => void = (e) => {
  }
  i: number = 0

  aboutToAppear() {
    console.log("拿到日历数据：" + this.monthEntity.daySize())
  }

  build() {
    Column() {
      //Text(`单个日历控件刷新次数刷新次数：${this.i++},${JSON.stringify(this.monthEntity.dateList[0])}}`)
      Text(this.monthEntity.title)
      GridRow({ columns: 7 }) {
        ForEach(this.monthEntity.dateList, (dateItem: CalendarDateViewModel, index) => {
          GridCol({ offset: index == 0 ? this.monthEntity.getMonthStartOffset() : 0 }) {
            CalendarDate({ dateEntity: dateItem })
              .onClick(() => {
                if (!dateItem.isAvailable) {
                  return
                }
                this.event.call(this.event, dateItem)
              })
          }
        })
      }
    }
  }
}

@Component
struct CalendarDate {
  @ObjectLink private dateEntity: CalendarDateViewModel

  build() {
    Column() {
      Stack() {
        if (this.dateEntity.isEndDuration() || this.dateEntity.isStartDuration()) {
          Row() {
            Stack().width("50%")
              .height("100%")
              .backgroundColor(this.dateEntity.isEndDuration() ? 0xFFCCEEEE : Color.Transparent)
            Stack().width("50%")
              .height("100%")
              .backgroundColor(this.dateEntity.isStartDuration() ? 0xFFCCEEEE : Color.Transparent)
          }
          .width('100%')
          .aspectRatio(2)
          .visibility(this.dateEntity.isEndDuration() && this.dateEntity.isStartDuration() ? Visibility.None : Visibility.Visible)
        }
        Button({ type: ButtonType.Circle })
          .backgroundColor(0x29B7B7)
          .width('50%')
          .height('100%')
          .visibility(this.getBottomDesc() ? Visibility.Visible : Visibility.Hidden)
        Text(`${this.dateEntity.showText()}`)
          .fontSize(16)
            /*.padding({
              top: 10,
              bottom: 10
            })*/
          .width("100%")
          .fontColor(this.dateEntity.isAvailable ? Color.Black : Color.Gray)
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(this.dateEntity.isOnlyDuration() ? 0xFFCCEEEE : Color.Transparent)

      Text(`${this.getBottomDesc()}`)
        .maxLines(1)
        .fontSize(14)
        .width("100%")
        .textAlign(TextAlign.Center)
        .visibility(this.getBottomDesc() ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Center)
  }

  isStartEnd() {
    return this.dateEntity.isStartDuration() || this.dateEntity.isEndDuration()
  }

  getBottomDesc() {
    return this.dateEntity.getBottomDesc()
  }
}