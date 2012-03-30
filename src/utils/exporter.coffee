# Generate and download a file from a string.
# On Chrome will force download, on Firefox will open a new window.
class Exporter

    mime:     'text/plain'
    charset:  'UTF-8'
    url:      (window.webkitURL or window.URL)

    # Use BlobBuilder and URL to force download dynamic string as a file.
    # `a`:        $ <a/>
    # `data`:     string to download
    # `filename`: take a guess...
    constructor: (a, data, filename = 'widget.tsv') ->
        # Get BlobBuilder.
        builder = new (window.WebKitBlobBuilder or window.MozBlobBuilder or window.BlobBuilder)()

        # Populate.
        builder.append data

        a.attr 'download', filename # download
        (@href = @url.createObjectURL builder.getBlob "#{@mime};charset=#{@charset}") and (a.attr 'href', @href) # href
        a.attr 'data-downloadurl', [ @mime, filename, @href ].join ':' # data-downloadurl

    # Revoke.
    destroy: => @url.revokeObjectURL @href


# For old browsers.
class PlainExporter

    # Create a new window with a formatted content.
    # `data`:     string to download
    constructor: (data) ->
        w = window.open()
        w.document.open()
        w.document.write data
        w.document.close()

    destroy: ->