Charts = {}

class Charts.MultipleBars

    # Size.
    width:  420
    height: 200

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')
        .attr('width', @width)

    render: () ->
        # How much padding from left?
        padding = @_textLength() * 6

        @width = @width - padding ; @height = @height - 15

        @chart = @canvas.append("svg:g").attr("class", "chart").attr("transform", "translate(#{padding},15)")
        
        # Get the domain.
        domain = @_domain()

        # Draw the grid.
        @grid domain            

        # The bars.
        for i, group of @series
            g = @chart
            .append("svg:g")
            .attr("class", "group g#{i}")
            
            j = 0
            
            for series, value of group['data']
                height = domain['y'].rangeBand() / 2
                top =    domain['y'](i) + (j * height)
                value =  domain['x'](value)

                g.append("svg:rect")
                .attr("class",  series)
                .attr('y',      top)
                .attr('width',  value)
                .attr('height', height)

                j++

            # Add description.
            @canvas.append("svg:text")
            .attr("class", "text")
            .attr('y', top + height)
            .text(group['text'])


    # Draw the grid.
    grid: (domain) ->
        g = @chart.append("svg:g").attr("class", "grid")
        
        g.selectAll("line")
        .data(domain['x'].ticks(10))
        .enter()
        .append("svg:line")
        .attr("x1", domain['x'])
        .attr("x2", domain['x'])
        .attr("y1", 0)
        .attr("y2", @height)

        # The grid values.
        g.selectAll(".rule")
        .data(domain['x'].ticks(10))
        .enter()
        .append("svg:text")
        .attr("class", "rule")
        .attr("x", domain['x'])
        .attr("y", 0)
        .attr("dy", -3)
        .attr("text-anchor", "middle")
        .text(String)       

    # Get the domain.
    _domain: () ->
        {
            'x': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @width ])
            'y': d3.scale.ordinal().domain([0..@series.length - 1]).rangeBands([ 0, @height ], .05)
        }

    # Determine the maximum size of text we will need to accommodate.
    _textLength: () ->
        max = -Infinity
        for group in @series
            max = group['text'].length if group['text'].length > max
        max        

    # Get a maximum value from series.
    _max: () ->
        max = -Infinity
        for group in @series
            for key, value of group['data']
                max = value if value > max
        max