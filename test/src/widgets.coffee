describe "Public Widgets Interface", ->
    w = new Widgets "http://"

    it "should be initialized by passing a service url", ->
        w.service.should.exist
        w.service.should.equal 'http://'

    it "should have these 3 public methods", ->
        w.chart.should.exist
        w.enrichment.should.exist
        w.all.should.exist