import { CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy } from './ICalendarStrategy';
import LinkedList from '@ohos.util.LinkedList';
import { RangeDateStrategy } from './RangeDateStrategy';

/**
 * 固定租期
 */
export class FixDayStrategy extends BaseCalendarStrategy {
  private _preStartIndex = -1

  constructor(private _fixDay: number) {
    super()
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
    let index = start
    while (index <= end) {
      let dateItem: CalendarDateViewModel = dateList[index]
      if (index == start) {
        dateItem.choose(true)
        console.log(`选择的开始日期：${dateItem.showText()}`)
      }
      dateItem.duration = true
      if (index == end) {
        dateItem.choose(false)
        console.log(`选择的结束日期：${dateItem.showText()}`)
      }
      index++
    }
    this._preStartIndex = start
  }

  reset() {
    super.reset()
    this.resetPre()
    this._preStartIndex = -1
  }
}