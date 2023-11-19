import { CalendarUtil } from './helper/CalendarUtil'
import { CalendarDateViewModel, CalendarMonthEntity, CalendarViewModel } from './viewmodel/CalendarEntity'
import { LazyDataSource } from './viewmodel/LazyDataSource'
import emitter from '@ohos.events.emitter'
import promptAction from '@ohos.promptAction'

@Component
@Entry
struct CalendarPage {
  build() {
    Row() {
      CalendarScroll()
    }.height(300)
  }
}

@Component
export struct CalendarScroll {
  private scroller: Scroller = new Scroller()
  @State private lazyMonthList: LazyDataSource<CalendarMonthEntity> = new LazyDataSource()
  private calendarVm: CalendarViewModel

  aboutToAppear() {
    this.fetchData()
  }

  fetchData() {
    let dateList: Array<CalendarMonthEntity> = CalendarUtil.createRangeDate()
    this.calendarVm = new CalendarViewModel(dateList)
    this.lazyMonthList.pushDataList(dateList)
  }

  build() {
    Column({}) {
      List({
        scroller: this.scroller
      }) {
        LazyForEach(this.lazyMonthList, (month: CalendarMonthEntity) => {
          ListItem() {
            CalendarMonth({ monthEntity: month, event: dateItem => {
              promptAction.showToast({ message: "time:" + dateItem.timeStamp })
              this.calendarVm.choose(dateItem)
            } })
          }
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

  aboutToAppear() {
    console.log("拿到日历数据：" + this.monthEntity.daySize())
  }

  build() {
    Column() {
      Text(this.monthEntity.title)
      GridRow({ columns: 7 }) {
        ForEach(this.monthEntity.dateList, (dateItem: CalendarDateViewModel, index) => {
          GridCol() {
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
        if (this.dateEntity.isEndDuration() || this.dateEntity.isStartDuration()){
          Row(){
            Stack().width("50%")
              .height("100%")
              .backgroundColor( this.dateEntity.isEndDuration()? 0xFFF1EAFF : Color.Transparent)
            Stack().width("50%")
              .height("100%")
              .backgroundColor( this.dateEntity.isStartDuration()? 0xFFF1EAFF : Color.Transparent)
          }
          .width('100%')
          .aspectRatio(2)
          .visibility(this.dateEntity.isEndDuration() && this.dateEntity.isStartDuration() ? Visibility.None : Visibility.Visible)
        }
        Button({ type: ButtonType.Circle })
          .backgroundColor(0xFFF1EAFF)
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
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(this.dateEntity.isOnlyDuration() ? 0xFFF1EAFF : Color.Transparent)

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