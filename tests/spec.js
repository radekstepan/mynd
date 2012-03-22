(function() {

  describe("InterMineWidget", function() {
    return it("should not be accessible", function() {
      expect(function() {
        return new InterMineWidget();
      }).toThrow();
      expect(function() {
        return new ChartWidget();
      }).toThrow();
      return expect(function() {
        return new EnrichmentWidget();
      }).toThrow();
    });
  });

  describe("Widgets", function() {
    var w;
    w = new Widgets("http://");
    it("should be initialized by passing a service url", function() {
      expect(w.service).toBeDefined();
      return expect(w.service).toEqual("http://");
    });
    return it("should have these 3 public methods", function() {
      expect(w.chart()).toBeDefined();
      expect(w.enrichment()).toBeDefined();
      return expect(w.all()).toBeDefined();
    });
  });

}).call(this);
