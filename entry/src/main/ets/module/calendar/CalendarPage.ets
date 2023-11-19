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
    setTimeout(() => {
      let dateList: Array<CalendarMonthEntity> = CalendarUtil.createRangeDate()
      this.calendarVm = new CalendarViewModel(dateList)
      this.lazyMonthList.pushDataList(dateList)
      // this.lazyMonthList.pushData(dateList[0])
    }, 1000)

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
      Text(`${this.dateEntity.showText()}`)
        .fontSize(16)
        .padding({
          top: 10,
          bottom: 10
        })
        .width("100%")
        .textAlign(TextAlign.Center)
      Text(`${this.dateEntity.getBottomDesc()}`)
        .maxLines(1)
        .fontSize(14)
        .width("100%")
        .textAlign(TextAlign.Center)
        .visibility(this.dateEntity.getBottomDesc() ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.dateEntity.isDuration ? 0xFFC683D7 : 0x33333333)
  }
}