import { CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy } from './ICalendarStrategy';
import LinkedList from '@ohos.util.LinkedList';
import { CalendarUtil } from '../helper/CalendarUtil';

export let TYPE_DAY_PICKER = "DayPickerStrategy"
export class DayPickerStrategy extends BaseCalendarStrategy {
  private _chooseDate: CalendarDateViewModel

  createCalendarData() {
    return CalendarUtil.createRangeDate(TYPE_DAY_PICKER)
  }

  choose(date: CalendarDateViewModel) {
    if (this._chooseDate != null) {
      this._chooseDate.reset()
    }
    this._chooseDate = date
    date.choose(true)
    this.onSelected(date.timeStamp, date.timeStamp)
  }

  reset() {
    super.reset()
    if (this._chooseDate != null) {
      this._chooseDate.reset()
    }
    this._chooseDate = null
  }
}