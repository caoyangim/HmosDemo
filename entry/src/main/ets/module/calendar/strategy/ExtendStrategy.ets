import { CalendarUtil } from '../helper/CalendarUtil';
import { CalendarMonthEntity, CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy, TimeLimit } from './ICalendarStrategy';
import promptAction from '@ohos.promptAction';

/**
 * 续租模式。_startTimeStamp 订单开始时间；_endTimeStamp 订单结束时间，只能从订单结束时间后开始选择，且只能选择结束时间
 */
export class ExtendStrategy extends BaseCalendarStrategy {
  private _chooseStartDate: CalendarDateViewModel
  private _chooseEndDate: CalendarDateViewModel

  constructor(private _orderStartTimeStamp: number, private _orderEndTimeStamp: number) {
    super()
    this.limitDate()
  }

  limitDate() {
    const startTimeStamp = this._orderStartTimeStamp
    const orderEndTimeStamp = this._orderEndTimeStamp
    let tmpChooseStart: CalendarDateViewModel
    let tmpChooseEnd: CalendarDateViewModel
    for (let i = 0; i < this._dateList.length; i++) {
      const dateItem = this._dateList[i]
      if (dateItem.timeStamp < startTimeStamp) {
        dateItem.Available = false
        tmpChooseStart = dateItem
        continue
      }
      // 选中且不可更改的状态
      if (dateItem.timeStamp < orderEndTimeStamp) {
        dateItem.Available = false
        dateItem.duration = true
        tmpChooseEnd = dateItem
        continue
      }
      break
    }
    this.chooseStart(tmpChooseStart)
    this._chooseEndDate = tmpChooseEnd
    tmpChooseEnd.Available = true
    tmpChooseEnd.duration = true
    tmpChooseEnd.choose(false)
  }

  private chooseStart(startDate: CalendarDateViewModel) {
    this._chooseStartDate = startDate;
    startDate.duration = true
    startDate.choose(true)
  }

  choose(date: CalendarDateViewModel) {
    if (!date.isAvailable) {
      promptAction.showToast({ message: "当前时间不可选" })
      return
    }
    if (this._chooseEndDate != null && this._chooseEndDate != undefined) {
      this.reset()
      this._chooseEndDate.reset()
    }
    this._chooseEndDate = date
    date.choose(false)
    this.onRanged()
    this.onRealSelected()
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
    this.limitDate()
    this.onRealSelected()
  }

  createCalendarData(): CalendarMonthEntity[] {
    // Math.random() 防止type重复，列表不刷新
    return CalendarUtil.createRangeDate("ExtendStrategy" + Math.random())
  }

  setOnSelectedEvent(event: (startTime: number, endTime: number) => void) {
    super.setOnSelectedEvent(event)
    this.onRealSelected()
  }

  onRealSelected() {
    let startDate = this._chooseStartDate
    let endDate = this._chooseEndDate
    if (startDate != null && endDate != null) {
      this.onSelected(startDate.timeStamp, endDate.timeStamp)
      this.changeTimeLimitIf()
    }
  }

  fixStartTime() {
    return true
  }

  changeTimeLimitIf() {
    const timeVm = this._takeReturnTimeVm
    const interval = CalendarUtil.getTimeInterval()
    const isEndDate = new Date(this._chooseEndDate.timeStamp).setHours(0, 0, 0, 0) == new Date(this._orderEndTimeStamp).setHours(0, 0, 0, 0)
    if (isEndDate) {
      promptAction.showToast({ message: "选择了订单结束日期" })
      timeVm.endTimeMin = this.startTimeRoundDown(this._orderEndTimeStamp, interval)
      timeVm.endTimeMax = new Date(this._orderEndTimeStamp).setHours(21, 30, 0)
    } else {
      promptAction.showToast({ message: "选择了其他日期" })
      timeVm.endTimeMin = new Date().setHours(7, 0, 0)
      timeVm.endTimeMax = new Date().setHours(21, 30, 0)
    }
  }

  getStartTimeLimit(): TimeLimit {
    let interval = CalendarUtil.getTimeInterval()
    let startMinLimit = this.startTimeRoundDown(this._orderStartTimeStamp, interval)
    let startMaxLimit = this.closeTimeRoundUp(this._orderStartTimeStamp, interval)
    return { minLimit: startMinLimit, maxLimit: startMaxLimit, interval: interval }
  }

  isChooseOrderEndDate(): boolean {
    let isEndDate = new Date(this._chooseEndDate.timeStamp).setHours(0, 0, 0, 0) == new Date(this._orderEndTimeStamp).setHours(0, 0, 0, 0)
    if (isEndDate) {
      console.log("选择了订单结束日期")
    }
    return isEndDate
  }
}
