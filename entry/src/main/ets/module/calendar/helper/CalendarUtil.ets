import { TYPE_DAY_PICKER } from '../strategy/DayPickerStrategy'
import { CalendarDateViewModel, CalendarMonthEntity } from '../viewmodel/CalendarEntity'

const TAG = "CalendarUtil"
const MAX_RETURN_INTERVAL = 365
export const ON_DAY_TIME_STAMP = 24 * 60 * 60 * 1000
export const INIT_TIME_CURRENT_TIME_ZONE = new Date(1970, 0, 0, 0, 0, 0)

export class CalendarUtil {
  static createRangeDate(type: string): Array<CalendarMonthEntity> {
    let currentDate = new Date()
    let limitDate = new Date()
    limitDate.setDate(currentDate.getDate() + MAX_RETURN_INTERVAL)
    this.log(`最长选择时间${limitDate}`)
    var spaceMonth: number = this.spaceMonth(currentDate, limitDate)
    this.log(`间隔月份：${spaceMonth}`)
    let monthList = new Array<CalendarMonthEntity>()
    if (spaceMonth < 0) {
      return monthList
    }
    let currentY = currentDate.getFullYear()
    let currentM = currentDate.getMonth()
    let currentDateWithoutHour = new Date(currentY, currentM, currentDate.getDate())
    while (spaceMonth >= 0) {
      let monthDay: number = this.getMonthDaysCount(currentY, currentM)
      let dateList = new Array<CalendarDateViewModel>()
      for (let dateIndex = 0; dateIndex < monthDay; dateIndex++) {
        let entity = new CalendarDateViewModel(currentY, currentM, dateIndex + 1, type)
        if (type == TYPE_DAY_PICKER) {
          entity.setBottomDesc("出发")
        }
        if (entity.timeStamp < currentDateWithoutHour.getTime()) {
          entity.Available = false
        }
        dateList.push(entity)
      }
      monthList.push(new CalendarMonthEntity(type, currentY, currentM, dateList))
      // 跨年
      if (currentM == 11) {
        currentY++
        currentM = 0
      } else {
        currentM++
      }
      spaceMonth--
    }
    return monthList
  }

  static spaceMonth(startDate: Date, endDate: Date): number {
    let startY = startDate.getFullYear()
    let startM = startDate.getMonth()
    let endY = endDate.getFullYear()
    let endM = endDate.getMonth()
    // 可能为负数
    let diffM = endM - startM
    if (startY == endY) {
      return diffM
    }
    let diffY = endY - startY
    return diffY * 12 + diffM
  }

  static getMonthDaysCount(year: number, month: number): number {
    if (month == 0 || month == 2 || month == 4 || month == 6 || month == 7 || month == 9 || month == 11) {
      return 31
    }
    if (month == 3 || month == 5 || month == 8 || month == 10) {
      return 30
    }
    if (month == 1) {
      return this.isLeapYear(year) ? 29 : 28
    }
    return -1
  }

  static isLeapYear(year: number): boolean {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  static getTimeInterval(): number {
    return this.getTimes(0, 30) * 1000
  }

  static getTimes(hour: number, minute): number {
    return hour * 3600 + minute * 60
  }

  static log(message: any) {
    console.log(TAG, message)
  }
}

// CalendarUtil.createRangeDate()


