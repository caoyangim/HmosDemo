@Preview
@Component
export struct DateReshowWidget {
  @Prop startTimeStamp: number
  @Prop endTimeStamp: number

  build() {
    Row() {
      Column() {
        Text(this.parseTime(this.startTimeStamp, true).month).fontSize(20).fontWeight(FontWeight.Bold)
        Text(this.parseTime(this.startTimeStamp, true).date)
      }.alignItems(HorizontalAlign.Start)

      Line()
        .startPoint([0, 0])
        .endPoint([60, 0])
        .stroke(Color.Gray)
        .strokeWidth(2)
      Column() {
        Text(this.parseTime(this.endTimeStamp, false).month).fontSize(20).fontWeight(FontWeight.Bold)
        Text(this.parseTime(this.endTimeStamp, false).date)
      }.alignItems(HorizontalAlign.End)
    }.width("100%").justifyContent(FlexAlign.SpaceBetween)
  }

  private weekChinese = ["日", "一", "二", "三", "四", "五", "六"]

  parseTime(timeStamp: number, isStar: boolean) {
    if (timeStamp == undefined || timeStamp == null || timeStamp <= 0) {
      return { month: isStar ? "取车日期" : "还车日期", date: "请选择" };
    }
    const tmpDate = new Date(timeStamp)
    const month = String(tmpDate.getMonth() + 1).padStart(2, '0')
    const dayDate = String(tmpDate.getDate()).padStart(2, '0')
    const day = "周" + this.weekChinese[tmpDate.getDay()]
    const hour = String(tmpDate.getHours()).padStart(2, '0')
    const minute = String(tmpDate.getMinutes()).padStart(2, '0')
    return { month: `${month}月${dayDate}日`, date: `${day} ${hour}:${minute}` };
  }
}
