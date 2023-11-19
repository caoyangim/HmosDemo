import {  CalendarDateViewModel, CalendarMonthEntity } from '../viewmodel/CalendarEntity'

const TAG = "CalendarUtil"
const MAX_RETURN_INTERVAL = 365

export class CalendarUtil {
  static createRangeDate(): Array<CalendarMonthEntity> {
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
    while (spaceMonth >= 0) {
      let monthDay: number = this.getMonthDaysCount(currentY, currentM)
      let dateList = new Array<CalendarDateViewModel>()
      for (let dateIndex = 0; dateIndex < monthDay; dateIndex++) {
        let entity = new CalendarDateViewModel(currentY, currentM, dateIndex + 1)
        dateList.push(entity)
      }
      monthList.push(new CalendarMonthEntity(`${currentY}年${currentM + 1}月`, dateList))
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
    return year % 3 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  static log(message: any) {
    console.log(TAG, message)
  }
}

// CalendarUtil.createRangeDate()


