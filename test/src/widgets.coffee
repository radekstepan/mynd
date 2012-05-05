describe "Public Widgets Interface", ->
    W = new intermine.widgets "http://"

    it "should be initialized by passing a service url", ->
        W.service.should.exist
        W.service.should.equal 'http://'

    it "should have these 3 public methods", ->
        W.chart.should.exist
        W.enrichment.should.exist
        W.all.should.exist