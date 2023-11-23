import { CalendarDateViewModel, CalendarMonthEntity } from '../viewmodel/CalendarEntity';
import LinkedList from '@ohos.util.LinkedList';
import { CalendarUtil } from '../helper/CalendarUtil';

interface ICalendarStrategy {

  getMonthList(): Array<CalendarMonthEntity>

  choose(date: CalendarDateViewModel)

}

export abstract class BaseCalendarStrategy implements ICalendarStrategy {
  private _monthList: Array<CalendarMonthEntity>
  protected _dateList: Array<CalendarDateViewModel>

  constructor() {
    this._monthList = CalendarUtil.createRangeDate()
    this._dateList = []
    this._monthList.forEach(monthEntity => {
      monthEntity.dateList.forEach(dateEntity => {
        this._dateList.push(dateEntity)
      })
    })
  }

  abstract choose(date: CalendarDateViewModel)

  getMonthList(): Array<CalendarMonthEntity> {
    return this._monthList
  }

  reset() {
    this._monthList.forEach(monthVm => {
      monthVm.dateList.forEach(item => {
        item.reset()
      })
    })
    this._dateList.forEach(item => {
      item.reset()
    })
  }
}