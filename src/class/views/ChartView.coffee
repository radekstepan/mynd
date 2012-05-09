### View maintaining Chart Widget.###

class ChartView extends Backbone.View

    events:
        "change div.form select": "formAction"

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "chart",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Extra attributes (DataSets etc.)?
        if @response.filterLabel?
            $(@el).find('div.form form').append @template "extra",
                "label":    @response.filterLabel
                "possible": @response.filters.split(',') # Is a String unfortunately.
                "selected": @response.filterSelectedValue

        # Are the results empty?
        if @response.results.length > 1
            # Form the series from Google Visualization formatted data.
            data = []
            for i, v of @response.results
                if i > 0 then data.push
                    'text': v[0]
                    'data':
                        'Blues':  v[1]
                        'Greens': v[2]

            # Determine the height of the svg canvas it should occupy.
            height = $(@widget.el).height() - $(@widget.el).find('header').height()

            chart = new Charts.MultipleBars.Vertical(
                'el':     $(@el).find("div.content")
                'data':   data
                'width':  420
                'height': height
            )
            chart.render()

        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()