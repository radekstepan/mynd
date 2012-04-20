### View maintaining Chart Widget.###

class ChartView extends Backbone.View

    events:
        "change div.form select": "formAction"

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "chart.normal",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Extra attributes (DataSets etc.)?
        if @response.filterLabel?
            $(@el).find('div.form form').append @template "chart.extra",
                "label":    @response.filterLabel
                "possible": @response.filters.split(',') # Is a String unfortunately.
                "selected": @response.filterSelectedValue

        # Are the results empty?
        if @response.results.length > 1
            graph = new Rickshaw.Graph(
                element:  $(@el).find("div.content")[0]
                renderer: "bar"
                series: [
                    data: [ {x:0, y:40}, {x:1, y:49} ]
                    color: "steelblue"
                ,
                    data: [ {x:0, y:20}, {x:1, y:24} ]
                    color: "lightblue"
                ]
            )
            graph.renderer.unstack = true
            graph.render()
        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()