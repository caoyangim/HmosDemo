import { CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy } from './ICalendarStrategy';
import LinkedList from '@ohos.util.LinkedList';
import { RangeDateStrategy } from './RangeDateStrategy';
import { CalendarUtil } from '../helper/CalendarUtil';

/**
 * 固定租期
 */
export class FixDayStrategy extends BaseCalendarStrategy {
  private _preStartIndex = -1

  constructor(private _fixDay: number) {
    super()
  }

  createCalendarData() {
    // Math.random() 防止type重复，列表不刷新
    return CalendarUtil.createRangeDate("FixDayStrategy" + Math.random())
  }

  choose(date: CalendarDateViewModel) {
    if (this._fixDay < 0) {
      return
    }
    let dateList: Array<CalendarDateViewModel> = this._dateList
    let start = dateList.findIndex(target => target.timeStamp == date.timeStamp)
    let end = start + this._fixDay
    if (start < 0 || end >= dateList.length) {
      return
    }
    this.resetPre()
    this.realChoose(start, end)
  }

  resetPre() {
    if (this._preStartIndex < 0) {
      return
    }
    let dateList: Array<CalendarDateViewModel> = this._dateList
    let index = this._preStartIndex
    let end = this._preStartIndex + this._fixDay
    while (index <= end) {
      let dateItem: CalendarDateViewModel = dateList[index]
      dateItem.reset()
      index++
    }
  }

  realChoose(start: number, end: number) {
    let dateList: Array<CalendarDateViewModel> = this._dateList
    if (start < 0 || end >= dateList.length) {
      return
    }
    let startItem: CalendarDateViewModel, endItem: CalendarDateViewModel
    let index = start
    while (index <= end) {
      let dateItem: CalendarDateViewModel = dateList[index]
      if (index == start) {
        startItem = dateItem
        dateItem.choose(true)
        console.log(`选择的开始日期：${dateItem.showText()}`)
      }
      dateItem.duration = true
      if (index == end) {
        endItem = dateItem
        dateItem.choose(false)
        console.log(`选择的结束日期：${dateItem.showText()}`)
      }
      index++
    }
    this._preStartIndex = start
    this.onSelected(startItem.timeStamp, endItem.timeStamp)
  }

  reset() {
    super.reset()
    this.resetPre()
    this._preStartIndex = -1
  }
}