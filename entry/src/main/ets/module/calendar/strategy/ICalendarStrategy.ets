import { CalendarDateViewModel, CalendarMonthEntity } from '../viewmodel/CalendarEntity';
import { CalendarUtil } from '../helper/CalendarUtil';
import { TakeReturnTimeViewModel } from '../component/TakeReturTimeChooseWidget';

interface ICalendarStrategy {

  getMonthList(): Array<CalendarMonthEntity>

  choose(date: CalendarDateViewModel)

  getTakeReturnTimeVm(): TakeReturnTimeViewModel
}

export abstract class BaseCalendarStrategy implements ICalendarStrategy {
  protected _monthList: Array<CalendarMonthEntity>
  protected _dateList: Array<CalendarDateViewModel>
  private _onSelectedEvent: (startTime: number, endTime: number) => void
  protected  _takeReturnTimeVm: TakeReturnTimeViewModel = new TakeReturnTimeViewModel()

  constructor() {
    this._monthList = this.createCalendarData()
    this._dateList = []
    this._monthList.forEach(monthEntity => {
      monthEntity.dateList.forEach(dateEntity => {
        this._dateList.push(dateEntity)
      })
    })
    this.initTimeVm()
  }

  private initTimeVm() {
    let startTimeLimit = this.getStartTimeLimit()
    let startTimeMin = startTimeLimit.minLimit
    let startTimeMax = startTimeLimit.maxLimit
    let startTimeInterval = startTimeLimit.interval
    let endTimeLimit = this.getEndTimeLimit()
    let endTimeMin = endTimeLimit.minLimit
    let endTimeMax = endTimeLimit.maxLimit
    let endTimeInterval = endTimeLimit.interval
    this._takeReturnTimeVm = new TakeReturnTimeViewModel(this.fixStartTime(), startTimeMin, startTimeMax, endTimeMin, endTimeMax,
      startTimeInterval, endTimeInterval)
  }

  fixStartTime(): boolean {
    return false
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

  getTakeReturnTimeVm(): TakeReturnTimeViewModel {
    return this._takeReturnTimeVm
  }

  getStartTimeLimit(): TimeLimit {
    return {
      minLimit: new Date().setHours(8, 0, 0),
      maxLimit: new Date().setHours(17, 30, 0),
      interval: CalendarUtil.getTimeInterval()
    }
  }

  getEndTimeLimit(): TimeLimit {
    return {
      minLimit: new Date().setHours(8, 0, 0),
      maxLimit: new Date().setHours(17, 30, 0),
      interval: CalendarUtil.getTimeInterval()
    }
  }

  /**
   * 起始时间向下取整
   */
  startTimeRoundDown(timeStamp: number, timeInterval: number): number {
    return Math.floor(timeStamp / timeInterval) * timeInterval;
  }

  /**
   * 结束时间向上取整
   */
  closeTimeRoundUp(timeStamp: number, timeInterval: number): number {
    if (timeStamp % timeInterval == 0) {
      return timeStamp;
    }
    return Math.floor((timeStamp + timeInterval) / timeInterval) * timeInterval;
  }
}

export interface TimeLimit {
  readonly minLimit: number
  readonly maxLimit: number
  readonly  interval: number
}