describe "Mynd", ->

    it "should select element", ->
        Mynd.select('body')

    it "should append element", ->
        Mynd.select(body)
        .append('svg:svg')

    it "should set attribute of element", ->
        Mynd.select(body)
        .append('svg:svg')
        .attr('class', 'clazz')