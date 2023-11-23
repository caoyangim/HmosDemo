import { ObservableArray } from './LazyDataSource'

const ONE_DAY_STAMP = 24 * 60 * 60 * 1000

@Observed
export class CalendarMonthEntity {
  private _title: string

  constructor(
    private _type: string,
    private _year: number,
    private _month: number,
    private _dateList: ObservableArray<CalendarDateViewModel>
  ) {
    this._title = `${_year}年${_month + 1}月`
  }

  public get type() {
    return this._type
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

  public get year() {
    return this._year
  }

  public get month() {
    return this._month
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
  private _isLastDayMonth = false

  constructor(
    private _year: number,
    private _month: number,
    private _date: number,
    private _type: string,
  ) {
    this.isToday = this.calculateIsToday(_year, _month, _date)
    this._isAvailable = true
    let date = new Date(_year, _month, _date)
    this._timeStamp = date.getTime()
    this._day = date.getDay()
    this.locationX = 0
    this.locationY = 0
    this._isLastDayMonth = new Date(this._timeStamp + ONE_DAY_STAMP).getDate() == 1
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

  private _bottomDesc?: string

  public setBottomDesc(text: string) {
    this._bottomDesc = text
  }

  public getBottomDesc(): string {
    let bottomDesc = this._bottomDesc
    if (this._isStart) {
      if (this._isEnd) {
        return bottomDesc ? bottomDesc : "取/还车"
      }
      return bottomDesc ? bottomDesc : "取车"
    }
    if (this._isEnd) {
      return bottomDesc ? bottomDesc : "还车"
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
    return this._isDuration && !this.isSpecial()
  }

  public isSpecial() {
    return this._isStart || this._isEnd || this.isSunday() || this.isSaturday() || this._isLastDayMonth || this.isFirstDayOfMonth()
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

  public isSunday() {
    return this._day == 0
  }

  public isSaturday() {
    return this._day == 6
  }

  public isFirstDayOfMonth() {
    return this._date == 1
  }

  public isLastDayOfMonth() {
    return this._isLastDayMonth
  }
}
