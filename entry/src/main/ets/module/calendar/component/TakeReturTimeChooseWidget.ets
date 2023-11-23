// 当前时区的 1970-01-01T00:00:00 ,用new Date(0)创建出来的是标准UTC时间
import { CalendarUtil } from '../helper/CalendarUtil'


@Component
@Preview
export struct TakeReturnTimeChooseWidget {
  @Link private startHourStamp: number
  @Link private endHourStamp: number
  @Link @Watch("onTimeVmChanged")
  private takeReturnTimeVm: TakeReturnTimeViewModel
  @State private readonly _startTimeList: string[] = []
  @State private readonly _EndTimeList: string[] = []

  fillTimeList(start: boolean, min: number, max: number, interval: number) {
    let list = start ? this._startTimeList : this._EndTimeList
    list.splice(0)
    if (min >= max) {
      const tmpDate = new Date(min)
      let hour = String(tmpDate.getHours()).padStart(2, '0')
      let minute = String(tmpDate.getMinutes()).padStart(2, '0')
      list.push(`${hour}:${minute}`)
      return
    }
    for (let i = min; i < max; i += interval) {
      const tmpDate = new Date(i)
      let hour = String(tmpDate.getHours()).padStart(2, '0')
      let minute = String(tmpDate.getMinutes()).padStart(2, '0')
      list.push(`${hour}:${minute}`)
    }
  }

  aboutToAppear() {
    this.onTimeVmChanged()
  }

  onTimeVmChanged() {
    let timeVm = this.takeReturnTimeVm
    console.log("------onTimeVmChanged start-----")
    this.logTimeStamp("最早取车时间:", timeVm.startTimeMin)
    this.logTimeStamp("最晚取车时间:", timeVm.startTimeMax)
    this.logTimeStamp("最早还车时间:", timeVm.endTimeMin)
    this.logTimeStamp("最晚还车时间:", timeVm.endTimeMax)
    this.log("_startTimeList:" + this._startTimeList)
    this.log("_EndTimeList:" + this._EndTimeList)
    console.log("------onTimeVmChanged end-----")
    this.fillTimeList(true, timeVm.startTimeMin, timeVm.startTimeMax, timeVm.startTimeInterval)
    this.fillTimeList(false, timeVm.endTimeMin, timeVm.endTimeMax, timeVm.endTimeInterval)
  }

  build() {
    Row() {
      Column() {
        Text("取车时间").fontWeight(FontWeight.Bold)
          .padding({ top: 10, bottom: 10 })
        TextPicker({
          range: this._startTimeList
        })
          .height(120)
          .onChange((value: string, index: number) => {
            console.log("取车TextPicker滑动导致startHourStamp改变")
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
    let tmpDate = new Date(hourStamp)
    const hour = String(tmpDate.getHours()).padStart(2, '0')
    const minute = String(tmpDate.getMinutes()).padStart(2, '0')
    return `${hour}:${minute}`
  }

  logTimeStamp(msg: string, timeStamp: number) {
    this.log(`${msg},${timeStamp}, ${new Date(timeStamp)}`)
  }

  log(msg: String) {
    console.log(`TakeReturnTimeChooseWidget: ${msg}`)
  }
}

const ONE_DAY_STAMP = 24 * 60 * 60 * 1000

export class TakeReturnTimeViewModel {
  constructor(
    public fixStartTime: boolean = false,
    public startTimeMin: number = 0,
    public startTimeMax: number = ONE_DAY_STAMP,
    public endTimeMin: number = 0,
    public endTimeMax: number = ONE_DAY_STAMP,
    public startTimeInterval: number = CalendarUtil.getTimeInterval(),
    public endTimeInterval: number = CalendarUtil.getTimeInterval(),
  ) {
  }
}