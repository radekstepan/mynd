describe "Mynd", ->

    beforeEach -> $('body').append($('<div/>', 'id': 'destroy'))

    afterEach -> $('#destroy').remove()
    
    it "should select element", ->
        selection = Mynd.select($('#destroy')[0]).elements
        
        console.log "mynd", selection

        selection.should.be.an 'array'
        selection.should.have.length 1
        
        selection[0].should.be.an 'array'
        selection[0].should.have.length 1

        $(selection[0]).get(0).tagName.toLowerCase().should.equal 'div'
        $(selection[0]).attr('id').should.equal 'destroy'

    it "should append element", ->
        selection = (Mynd.select($('#destroy')[0]).append('svg:svg')).elements

        selection.should.be.an 'array'
        selection.should.have.length 1
        
        selection[0].should.be.an 'array'
        selection[0].should.have.length 1

        $(selection[0]).get(0).tagName.toLowerCase().should.equal 'svg'

    it "should set element attribute", ->
        selection = (Mynd.select($('#destroy')[0]).append('svg:svg').attr('class', 'svg')).elements

        selection.should.be.an 'array'
        selection.should.have.length 1
        
        selection[0].should.be.an 'array'
        selection[0].should.have.length 1

        $(selection[0]).get(0).tagName.toLowerCase().should.equal 'svg'
        $(selection[0]).attr('class').toLowerCase().should.equal 'svg'