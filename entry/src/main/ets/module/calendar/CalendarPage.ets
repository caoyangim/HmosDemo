import { CalendarDateViewModel, CalendarMonthEntity } from './viewmodel/CalendarEntity'
import { LazyDataSource } from './viewmodel/LazyDataSource'
import promptAction from '@ohos.promptAction'
import { RangeDateStrategy } from './strategy/RangeDateStrategy'
import { DayPickerStrategy } from './strategy/DayPickerStrategy'
import { BaseCalendarStrategy } from './strategy/ICalendarStrategy'
import { FixDayStrategy } from './strategy/FixDayStrategy'
import { DateReshowWidget } from './component/DateReshowWidget'
import { TakeReturnTimeChooseWidget, TakeReturnTimeViewModel } from './component/TakeReturTimeChooseWidget'
import { ExtendStrategy } from './strategy/ExtendStrategy'

@Component
@Entry
struct CalendarPage {
  @State weekDays: string[] = ["日", "一", "二", "三", "四", "五", "六"]
  private strategyList = [new RangeDateStrategy(), new DayPickerStrategy(), new FixDayStrategy(0), new FixDayStrategy(2)
    , new ExtendStrategy(new Date().getTime(), new Date().getTime() + 36 * 60 * 60 * 1000)]
  private currentStrategy: BaseCalendarStrategy = this.strategyList[0]
  @State private monthList: CalendarMonthEntity[] = []
  @State private startTimeStamp: number = 0
  @State private endTimeStamp: number = 0
  private startDateStamp: number = 0
  private endDateStamp: number = 0
  @State @Watch("hourChanged")
  private startHourStamp: number = 0
  @State @Watch("hourChanged")
  private endHourStamp: number = 0
  @State private takeReturnTimeVm: TakeReturnTimeViewModel = new TakeReturnTimeViewModel()

  aboutToAppear() {
    this.changePosition(0)
  }

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
    this.currentStrategy.setOnSelectedEvent((startTime, endTime) => {
      this.startDateStamp = startTime
      this.endDateStamp = endTime
      this.startTimeStamp = startTime > 0 ? startTime + this.startHourStamp : 0
      this.endTimeStamp = endTime > 0 ? endTime + this.endHourStamp : 0
    })
    promptAction.showToast({ message: `当前模式：${this.currentStrategy.constructor.name}` })
    // this.logDateData()
    while (this.monthList.length != 0) {
      this.monthList.pop()
    }
    this.monthList.push(...this.currentStrategy.getMonthList())
    this.changeTimeViewModel()
  }

  changeTimeViewModel() {
    console.log("takeReturnTimeVm即将变化，马上刷新TakeReturnTimeWidget")
    this.takeReturnTimeVm = this.currentStrategy.getTakeReturnTimeVm()
  }

  logDateData() {
    let logData: CalendarMonthEntity = this.currentStrategy.getMonthList()[1]
    console.log(`当前${logData.title}数据 ：`);
    logData.dateList.forEach(date => {
      console.log(`${date.date}(start = ${date.isStart},end = ${date.isEnd},duration = ${date.isDuration})`);
    })
  }

  hourChanged() {
    let startDateStamp = this.startDateStamp
    let endDateStamp = this.endDateStamp
    this.startTimeStamp = startDateStamp > 0 ? startDateStamp + this.startHourStamp : 0
    this.endTimeStamp = endDateStamp > 0 ? endDateStamp + this.endHourStamp : 0
    console.log("监听到取/还车时间改变")
  }

  build() {
    Stack() {
      Column() {
        this.TopBanner()
        DateReshowWidget({ startTimeStamp: this.startTimeStamp, endTimeStamp: this.endTimeStamp })
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        this.WeekDayView()
        CalendarScroll({ monthList: this.monthList, event: (dateItem) => {
          promptAction.showToast({ message: "time:" + dateItem.timeStamp })
          if (this.currentStrategy == null) {
            return
          }
          console.log(`当前模式：${this.currentStrategy.constructor.name}`);
          this.currentStrategy.choose(dateItem)
        } }).layoutWeight(1)
        TakeReturnTimeChooseWidget({
          startHourStamp: $startHourStamp,
          endHourStamp: $endHourStamp,
          takeReturnTimeVm: this.takeReturnTimeVm
        })
        Row() {
        }.height(90)
      }.height("100%")

      this.ChooseType()
    }.align(Alignment.Bottom)
  }

  @Builder
  TopBanner() {
    Row() {
      Blank().layoutWeight(1)
      Text("清空")
        .padding({ left: 16, right: 16, top: 10, bottom: 5 })
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
          Text(day).fontSize(12)
        }
      })
    }.padding({ top: 5, bottom: 10 })
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
        value: '固定天数模式(1天)',
        action: () => {
          this.changePosition(2)
        }
      },
      {
        value: '固定天数模式(3天)',
        action: () => {
          this.changePosition(3)
        }
      },
      {
        value: '选择续租模式',
        action: () => {
          this.changePosition(4)
        }
      }
    ])
  }
}

@Component
export struct CalendarScroll {
  @Link @Watch("onDataSourceChanged")
  private monthList: CalendarMonthEntity[]
  @State private readonly lazyList: LazyDataSource<CalendarMonthEntity> = new LazyDataSource(this.monthList)
  private scroller: Scroller = new Scroller()
  private event: (date: CalendarDateViewModel) => void = (e) => {
  }

  onDataSourceChanged() {
    promptAction.showToast({ message: "日历列表数据源发生变化" })
    this.lazyList.notifyDataReload()
  }

  build() {
    Column({}) {
      List({
        scroller: this.scroller
      }) {
        LazyForEach(this.lazyList, (month: CalendarMonthEntity) => {
          ListItem() {
            CalendarMonth({ monthEntity: month, event: dateItem => {
              this.event.call(this.event, dateItem)
            } }).backgroundColor(0xF9F9F8)
          }
        }, (month: CalendarMonthEntity) => {
          return month.type + month.title
        })
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
      Text(this.monthEntity.title).alignSelf(ItemAlign.Start)
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
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
        if (this.dateEntity.isDuration) {
          Row() {
            Stack().width("50%")
              .height("100%")
              .backgroundColor(!this.hideFirstHalfRow() ? this.getBackgroundColor() : Color.Transparent)
            Stack().width("50%")
              .height("100%")
              .backgroundColor(!this.hideSecondHalfRow() ? this.getBackgroundColor() : Color.Transparent)
          }
          .width('100%')
          .aspectRatio(2)
          .visibility(this.dateEntity.isEndDuration() && this.dateEntity.isStartDuration() ? Visibility.None : Visibility.Visible)
        }
        if (this.dateEntity.isDuration && (this.dateEntity.isSunday() || this.dateEntity.isLastDayOfMonth()
        || this.dateEntity.isSaturday() || this.dateEntity.isFirstDayOfMonth())) {
          Button({ type: ButtonType.Circle })
            .backgroundColor(this.getBackgroundColor())
            .width('50%')
            .height('100%')
        }
        Button({ type: ButtonType.Circle })
          .backgroundColor(!this.dateEntity.isAvailable ? 0xFF999999 : 0xFF29B7B7)
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
          .fontColor(this.getTextColor())
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(this.dateEntity.isOnlyDuration() ? this.getBackgroundColor() : Color.Transparent)

      Text(`${this.getBottomDesc()}`)
        .maxLines(1)
        .fontSize(12)
        .width("100%")
        .textAlign(TextAlign.Center)
        .visibility(this.getBottomDesc() ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Center)
  }

  getBackgroundColor() {
    return this.dateEntity.isAvailable ? 0xFFCCEEEE : 0xFFEDEDED;
  }

  hideSecondHalfRow() {
    return this.dateEntity.isEndDuration() || this.dateEntity.isSaturday() || this.dateEntity.isLastDayOfMonth()
  }

  hideFirstHalfRow() {
    return this.dateEntity.isStartDuration() || this.dateEntity.isSunday() || this.dateEntity.isFirstDayOfMonth()
  }

  isStartEnd() {
    return this.dateEntity.isStartDuration() || this.dateEntity.isEndDuration()
  }

  getBottomDesc() {
    return this.dateEntity.getBottomDesc()
  }

  getTextColor() {
    if (this.dateEntity.isStart || this.dateEntity.isEnd) {
      return Color.White
    }
    return this.dateEntity.isAvailable ? Color.Black : Color.Gray
  }
}