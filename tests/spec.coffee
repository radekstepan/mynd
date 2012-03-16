describe "InterMineWidget", ->

    it "should not be accessible", ->
        expect( -> new InterMineWidget() ).toThrow()
        expect( -> new ChartWidget() ).toThrow()
        expect( -> new EnrichmentWidget() ).toThrow()

describe "Widgets", ->
    w = new Widgets("http://")

    it "should be initialized by passing a service url", ->
        expect(w.service).toBeDefined()
        expect(w.service).toEqual "http://"

    it "should have these 3 public methods", ->
        expect(w.chart()).toBeDefined()
        expect(w.enrichment()).toBeDefined()
        expect(w.all()).toBeDefined()