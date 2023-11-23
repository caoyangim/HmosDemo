import { CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy } from './ICalendarStrategy';

export class RangeDateStrategy extends BaseCalendarStrategy {
  private _chooseStartDate: CalendarDateViewModel
  private _chooseEndDate: CalendarDateViewModel

  choose(date: CalendarDateViewModel) {
    if (this._chooseStartDate == null) {
      this._chooseStartDate = date
      date.choose(true)
      return
    }
    if (this._chooseEndDate == null && this._chooseStartDate.timeStamp <= date.timeStamp) {
      this._chooseEndDate = date
      date.choose(false)
      this.onRanged()
      return
    }
    this._dateList.forEach(dateEntity => {
      dateEntity.reset()
    })
    this._chooseStartDate = date
    this._chooseEndDate = null
    date.choose(true)
  }

  /**
   * 范围选定
   */
  private onRanged() {
    let chooseStartDate = this._chooseStartDate
    let chooseEndDate = this._chooseEndDate
    let dateList = this._dateList
    if (chooseStartDate == null) {
      return
    }
    let hasChooseStart = false
    let hasChooseEnd = false
    dateList.forEach(dateEntity => {
      if (chooseStartDate == dateEntity) {
        console.log(`选择的开始日期：${dateEntity.showText()}`)
        hasChooseStart = true
      }
      if (hasChooseStart && !hasChooseEnd) {
        dateEntity.duration = true
      }
      if (chooseEndDate == dateEntity) {
        console.log(`选择的结束日期：${dateEntity.showText()}`)
        hasChooseEnd = true
      }
    })
  }

  reset() {
    super.reset()
    this._chooseStartDate = null
    this._chooseEndDate = null
  }
}