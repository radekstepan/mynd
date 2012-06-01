describe "Mynd", ->

    Mynd = intermine.mynd

    # Playground...
    reset = ->
        if $('#canvas').length is 0
            $('body').append($('<div/>', 'id': 'canvas'))
        else
            $('#canvas').html ''
    reset()

    it "should select element", ->
        reset()

        selection = Mynd.select($('#canvas')[0]).elements
        
        selection.should.be.an 'array'
        selection.should.have.length 1
        
        selection[0].should.be.an 'array'
        selection[0].should.have.length 1

        $(selection[0]).get(0).tagName.toLowerCase().should.equal 'div'
        $(selection[0]).attr('id').should.equal 'canvas'