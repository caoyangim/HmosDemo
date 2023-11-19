import { ObservableArray } from './LazyDataSource'
import LinkedList from '@ohos.util.LinkedList'

export class CalendarViewModel {
  private _chooseStartDate: CalendarDateViewModel
  private _chooseEndDate: CalendarDateViewModel
  private _dateList: LinkedList<CalendarDateViewModel>

  constructor(private _monthList: Array<CalendarMonthEntity>) {
    this._dateList = new LinkedList()
    _monthList.forEach(monthEntity => {
      monthEntity.dateList.forEach(dateEntity => {
        this._dateList.add(dateEntity)
      })
    })
  }

  public choose(date: CalendarDateViewModel) {
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
}

@Observed
export class CalendarMonthEntity {
  constructor(
    private _title: string,
    private _dateList: ObservableArray<CalendarDateViewModel>
  ) {
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

  constructor(
    private _year: number,
    private _month: number,
    private _date: number,
  ) {
    this.isToday = this.calculateIsToday(_year, _month, _date)
    this._isAvailable = true
    this._timeStamp = new Date(_year, _month, _date).getTime()
    this.locationX = 0
    this.locationY = 0
  }

  calculateIsToday(year: number, month: number, date: number) {
    let todayDate = new Date()
    return year == todayDate.getFullYear() && month == todayDate.getMonth() && date == todayDate.getDate()
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

  public get isAvailable() {
    return this._isAvailable
  }
}
