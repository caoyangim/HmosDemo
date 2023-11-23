// 当前时区的 1970-01-01T00:00:00 ,用new Date(0)创建出来的是标准UTC时间
import { CalendarUtil, INIT_TIME_CURRENT_TIME_ZONE } from '../helper/CalendarUtil'


@Component
@Preview
export struct TakeReturnTimeChooseWidget {
  @Link private startHourStamp: number
  @Link private endHourStamp: number
  @Link @Watch("onTimeVmChanged")
  private takeReturnTimeVm: TakeReturnTimeViewModel
  private readonly _startTimeList: string[] = []
  private readonly _EndTimeList: string[] = []

  fillTimeList(start: boolean, min: number, max: number, interval: number) {
    for (let i = min; i < max; i += interval) {
      let hour = String(Math.floor(i / 3600_000)).padStart(2, '0')
      let minute = String(i % 3600_000 / 60_000).padStart(2, '0')
      if (start) {
        this._startTimeList.push(`${hour}:${minute}`)
      } else {
        this._EndTimeList.push(`${hour}:${minute}`)
      }
    }
  }

  aboutToAppear() {
    this.onTimeVmChanged()
  }

  onTimeVmChanged() {
    let timeVm = this.takeReturnTimeVm
    this.fillTimeList(true, timeVm.startTimeMin, timeVm.startTimeMax, timeVm.startTimeInterval)
    this.fillTimeList(false, timeVm.endTimeMin, timeVm.endTimeMax, timeVm.endTimeInterval)
    this.logTimeStamp("取车最早时间:", timeVm.startTimeMin)
    this.logTimeStamp("取车最晚时间:", timeVm.startTimeMax)
    this.logTimeStamp("还车最晚时间:", timeVm.endTimeMin)
    this.logTimeStamp("还车最晚时间:", timeVm.endTimeMax)
  }

  build() {
    Row() {
      Column() {
        Text("取车时间").fontWeight(FontWeight.Bold)
          .padding({ top: 10, bottom: 10 })
        TextPicker({
          range: this.takeReturnTimeVm.fixStartTime ? [this.parseHourStamp(this.startHourStamp)] : this._startTimeList
        })
          .height(120)
          .onChange((value: string, index: number) => {
            let tmpDate = new Date(`1970/01/01 ${value}:00.000Z`)
            this.startHourStamp = tmpDate.getTime()
          })
      }

      Column() {
        Text("还车时间").fontWeight(FontWeight.Bold)
          .padding({ top: 10, bottom: 10 })
        TextPicker({ range: this._EndTimeList })
          .height(120)
          .onChange((value: string, index: number) => {
            let tmpDate = new Date(`1970/01/01 ${value}:00.000Z`)
            this.endHourStamp = tmpDate.getTime()
          })
      }
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  parseHourStamp(hourStamp: number): string {
    let tmpDate = new Date(INIT_TIME_CURRENT_TIME_ZONE.getTime() + hourStamp)
    const hour = String(tmpDate.getHours()).padStart(2, '0')
    const minute = String(tmpDate.getMinutes()).padStart(2, '0')
    return `${hour}:${minute}`
  }

  logTimeStamp(msg: string, timeStamp: number) {
    console.log(`TakeReturnTimeChooseWidget: ${msg} ${new Date(timeStamp)}`)
  }
}

export class TakeReturnTimeViewModel {
  fixStartTime: boolean = false
  startTimeMin: number = 0
  startTimeMax: number = 24 * 60 * 60 * 1000
  endTimeMin: number = 0
  endTimeMax: number = 24 * 60 * 60 * 1000
  startTimeInterval: number = CalendarUtil.getTimeInterval()
  endTimeInterval: number = CalendarUtil.getTimeInterval()
}