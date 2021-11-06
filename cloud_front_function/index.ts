import { CloudFrontRequest } from 'aws-lambda'

function handler (event: CloudFrontRequest):CloudFrontRequest {
  // Extract the URI from the request
  var newUrl = event.uri

  // Not Exists file extensions and last char is not '/''
  if (newUrl.split('.').length == 1 && newUrl.slice(-1) != '/') {
    newUrl += '/'
  }

  // Match any '/' that occurs at the end of a URI. Replace it with a default index
  newUrl = newUrl.replace(/\/$/, '\/index.html')

  // Replace the received URI with the URI that includes the index page
  event.uri = newUrl

  return event
}
