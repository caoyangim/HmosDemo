import { CalendarDateViewModel } from '../viewmodel/CalendarEntity';
import { BaseCalendarStrategy } from './ICalendarStrategy';
import LinkedList from '@ohos.util.LinkedList';

export class DayPickerStrategy extends BaseCalendarStrategy {
  private _chooseDate: CalendarDateViewModel

  choose(date: CalendarDateViewModel) {
    if (this._chooseDate != null) {
      this._chooseDate.reset()
    }
    this._chooseDate = date
    date.choose(true)
  }

  reset() {
    super.reset()
    if (this._chooseDate != null) {
      this._chooseDate.reset()
    }
    this._chooseDate = null
  }
}