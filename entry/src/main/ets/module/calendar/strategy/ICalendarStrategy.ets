import { CalendarDateViewModel, CalendarMonthEntity } from '../viewmodel/CalendarEntity';
import LinkedList from '@ohos.util.LinkedList';
import { CalendarUtil, ON_DAY_TIME_STAMP } from '../helper/CalendarUtil';

interface ICalendarStrategy {

  getMonthList(): Array<CalendarMonthEntity>

  choose(date: CalendarDateViewModel)

  getStartTimeLimit(): TimeLimit

  getEndTimeLimit(): TimeLimit
}

export abstract class BaseCalendarStrategy implements ICalendarStrategy {
  protected _monthList: Array<CalendarMonthEntity>
  protected _dateList: Array<CalendarDateViewModel>
  private _onSelectedEvent: (startTime: number, endTime: number) => void

  constructor() {
    this._monthList = this.createCalendarData()
    this._dateList = []
    this._monthList.forEach(monthEntity => {
      monthEntity.dateList.forEach(dateEntity => {
        this._dateList.push(dateEntity)
      })
    })
  }

  abstract createCalendarData(): Array<CalendarMonthEntity>

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
    this.onSelected(0, 0)
  }

  setOnSelectedEvent(event: (startTime: number, endTime: number) => void) {
    this._onSelectedEvent = event
  }

  onSelected(startTime: number, endTime: number) {
    let listener = this._onSelectedEvent
    if (listener == null || listener == undefined) {
      return
    }
    listener.call(listener, startTime, endTime)
  }

  getStartTimeLimit(): TimeLimit {
    return { minLimit: 0, maxLimit: ON_DAY_TIME_STAMP, interval: CalendarUtil.getTimeInterval() }
  }

  getEndTimeLimit(): TimeLimit {
    return { minLimit: 0, maxLimit: ON_DAY_TIME_STAMP, interval: CalendarUtil.getTimeInterval() }
  }

  /**
   * 起始时间向下取整
   */
  startTimeRoundDown(timeStamp: number, timeInterval: number): number {
    if (timeStamp % timeInterval == 0) {
      return timeStamp;
    }
    return (timeStamp + timeInterval) / timeInterval * timeInterval;
  }

  /**
   * 结束时间向上取整
   */
  closeTimeRoundUp(timeStamp: number, timeInterval: number): number {
    return timeStamp / timeInterval * timeInterval;
  }
}

export interface TimeLimit {
  readonly minLimit: number
  readonly maxLimit: number
  readonly  interval: number
}