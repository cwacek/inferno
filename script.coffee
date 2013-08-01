margin =
  top: 80
  right: 0
  bottom: 40
  left: 160

width = $("#chart").width() - margin.left - margin.right
gridSize = Math.floor(width / 24)
legendElementWidth = gridSize*2
height = (gridSize * 7) + margin.top
buckets = 9
colors = ["#3fe500", "#63e100", "#86dd00", "#a7d900", "#c7d500", "#d2be00", "#ce9800", "#ca7500", "#c65200", "#c23100", "#bf1000"]
#days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
times = ["12a", "1a", "2a", "3a", "4a", "5a", "6a", "7a", "8a", "9a", "10a", "11a", "12p", "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p", "10p", "11p"];

dataHandler = (d)->

getVal = (d)->
  return d.value

plotter = (error, data)->

  isOld = (date)->
    diff = (new Date() - date)/ (1000*60*60*24)
    if diff > 7
      return true
    false

  convert = (old)->
    ret = []
    for d in old
      date = new Date(d[0] * 1000)
      if not isOld(date)
        val =
          hour: date.getHours()
          day: do (date)->
            now = new Date()
            now.setHours(0,0,0,0)
            7 - Math.ceil( (now.getTime() - date.getTime()) / (24 *3600 * 1000))
          date: date.toLocaleDateString()
          value: parseFloat(d[1])
        ret.push(val)
    ret

  data = convert(data)
  days = do (data)->
    dp.date for dp in data when jQuery.inArray(dp.date, _results) == -1

  colorScale = d3.scale.quantile()
    .domain([55, d3.max(data, getVal)])
    .range(colors)

  svg = d3.select("#chart").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom + gridSize)
    .append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")


  dayLabels = svg.selectAll(".dayLabel").data(days)
    .enter().append('text')
      .text((d)->(d))
      .attr('x', 0)
      .attr('y', (d,i)->((i - 1) * gridSize))
      .style('text-anchor', 'end')
      .attr('transform', "translate(-#{1.5 * gridSize}, #{gridSize / 1.5})")
      .attr('class', (d, i)->("dayLabel mono axis"))

  timeLabels = svg.selectAll(".timeLabel")
                .data(times)
                .enter().append("text")
                  .text((d)->(d))
                  .attr("x", (d, i)->((i - 1) * gridSize))
                  .attr("y", 0)
                  .style("text-anchor", "middle")
                  .attr("transform", "translate(#{gridSize / 2}, -#{1.5 * gridSize})")
                  .attr("class", (d,i)->
                                    if i >= 7 and i <= 16
                                      "timeLabel mono axis axis-worktime"
                                    else 
                                      "timeLabel mono axis"
                  )

  heatMap = svg.selectAll(".hour")
                .data(data)
                .enter().append("rect")
                .attr("x", (d)->((d.hour - 1) * gridSize))
                .attr("y", (d)->((d.day - 1) * gridSize))
                .attr('data-dayoffset',(d)->(d.day))
                .attr("rx", 4)
                .attr("ry", 4)
                .attr("class", "hour bordered")
                .attr("width", gridSize)
                .attr("height", gridSize)
                .style("fill", colors[0])

  heatMap.transition().duration(1000)
                .style("fill", (d)->(colorScale(d.value)))

  heatMap.append("title").text((d)->("#{d.date} #{d.hour}:00 - #{d.value}"))


  legend = svg.selectAll(".legend")
              .data([0].concat(colorScale.quantiles()), (d)->(d))
              .enter().append("g")
              .attr("class", "legend");

  legend.append("rect")
              .attr("x", (d, i)->(legendElementWidth * i))
              .attr("y", (8 * gridSize))
              .attr("width", legendElementWidth)
              .attr("height", gridSize / 1.5)
              .style("fill", (d, i)->(colors[i]))

  legend.append("text")
              .attr("class", "mono")
              .text((d)->("> #{Math.round(d)}"))
              .attr("x", (d, i)->((legendElementWidth * i) + 5))
              .attr("y", (8 * gridSize)+ (gridSize / 2 ))

d3.json "temps.dat", plotter

