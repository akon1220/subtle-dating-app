# Backend for Search Cloud Function

The API is located at:
```
https://us-central1-subtle-eff3f.cloudfunctions.net/search
```

## Search

To perform text search, use the text query parameter. 

```
/search?text=<text>
```

All records partially matching the input text regardless of case sensitivity will be returned

## Pagination

To specifiy page to load, use the page query parameter in conjuction with num query parameter

```
/search?page=<pagenumber>num=<number>
```

page controls the page of data to retrieve, while num controls the number of hits per page

## Filtering

Currently, filtering is supported on text and numeric fields. 
The text fields supported are:
```
["location", "name", "university"]
```
with the following operators supported:
```
["=", "!="]
```

The numeric fields supported are
```
["birthday", "creationDate"]
```
with the following operators supported:
```
["<", ">", ">=", "<=", "=", "!="]
```

For filtering you must include query parameters for fields, operators, and values. 
For example:
```
/search?fields=university&operators==&values=Duke University
```
will search for all posts with university equal to Duke University

You can specify multiple filters like so:
```
/search?fields=university&operators==&values=Duke University&fields=university&operators===&values=Cornell University&fields=birthday&operators=>&values=0
```

will search for all posts with university equal to Duke University or Cornell university with a birthday greater than 0 of the Epoch Unix Timestamp. For all dates, convert to Epoch Unix Timestamp.

## Data Format

Returned Data will be in the format of:

```
{
    "hits" : {
        "hits : [
            Post1,
            Post2,
            ...
        ],
        "nbHits": int,
        "page": int,
        "nbPages": int,
        "hitsPerPage": int,
        "exhaustiveNbHits": bool,
        "exhaustiveTypo": bool,
        "query": str,
        "params": str,
        "renderingContent": any,
        "processingTimeMS": int
    }
}
```

