import { ObservableArray } from './LazyDataSource'

@Observed
export class CalendarMonthEntity {
  private _title
  constructor(
     _title: string,
    private _dateList: ObservableArray<CalendarDateViewModel>
  ) {
    this._title = _title+Date.parse(new Date().toString()) + Math.random()
  }

  public get title() {
    return this._title
  }

  public get dateList() {
    return this._dateList
  }

  public daySize() {
    return this._dateList.length
  }

  public getMonthStartOffset(): number {
    let dateList = this._dateList
    if (dateList == null || dateList.length == 0) {
      return -1
    }
    let firstDayOfMonth: CalendarDateViewModel = dateList[0]
    return firstDayOfMonth.day
  }
}

@Observed
export class CalendarDateViewModel {
  private _isStart: boolean
  private _isEnd: boolean
  private _isDuration: boolean = false
  private isToday: boolean
  private locationX: number
  private locationY: number
  private _isAvailable: boolean = true
  private _timeStamp: number
  private _day: number

  constructor(
    private _year: number,
    private _month: number,
    private _date: number,
  ) {
    this.isToday = this.calculateIsToday(_year, _month, _date)
    this._isAvailable = true
    let date = new Date(_year, _month, _date)
    this._timeStamp = date.getTime()
    this._day = date.getDay()
    this.locationX = 0
    this.locationY = 0
  }

  calculateIsToday(year: number, month: number, date: number) {
    let todayDate = new Date()
    return year == todayDate.getFullYear() && month == todayDate.getMonth() && date == todayDate.getDate()
  }

  public get day() {
    return this._day
  }

  public get date() {
    return this._date
  }

  public showText() {
    if (this.isToday) {
      return "今"
    }
    return this._date
  }

  public get timeStamp() {
    return this._timeStamp
  }

  public getBottomDesc(): string {
    if (this._isStart) {
      if (this._isEnd) {
        return "取/还车"
      }
      return "取车"
    }
    if (this._isEnd) {
      return "还车"
    }
    return null
  }

  public choose(start: boolean) {
    if (start) {
      this._isStart = true
      return
    }
    this._isEnd = true
  }

  public reset() {
    this._isStart = false
    this._isEnd = false
    this._isDuration = false
  }

  public set duration(duration: boolean) {
    this._isDuration = duration
  }

  public get isDuration() {
    return this._isDuration
  }

  public isOnlyDuration() {
    return this._isDuration && !this._isStart && !this._isEnd
  }

  public isStartDuration() {
    return this._isDuration && this._isStart
  }

  public isEndDuration() {
    return this._isDuration && this._isEnd
  }

  public get isAvailable() {
    return this._isAvailable
  }

  public set Available(available: boolean) {
    this._isAvailable = available
  }

  public get isStart() {
    return this._isStart
  }

  public get isEnd() {
    return this._isEnd
  }
}
