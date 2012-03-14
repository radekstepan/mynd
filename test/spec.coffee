describe "Widgets", ->
  w = new Widgets("http://")
  
  it "should be initialized by passing a service url", ->
    expect(w.service).toBeDefined()
    expect(w.service).toEqual "http://"