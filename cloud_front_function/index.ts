/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable no-var */

import { CloudFrontRequest } from 'aws-lambda'

type CloudFrontFunctionRequest = CloudFrontRequest & {
  request: CloudFrontRequest & {
    headers: {
      host: {
        value: string
      }
    }
  }
}

type CloudFrontFunctionResult =
    | {
  statusCode: number
  statusDescription?: string
  headers: {
    location: {
      value: string
    }
  }
} | CloudFrontRequest

function handler (event: CloudFrontFunctionRequest):CloudFrontFunctionResult {
  // Extract the URI from the request
  var request = event.request
  var newUrl = event.request.uri

  // Not Exists file extensions and last char is not '/''
  if (newUrl.split('.').length == 1 && newUrl.slice(-1) != '/') {
    newUrl += '/'
  }

  // Match any '/' that occurs at the end of a URI. Replace it with a default index
  newUrl = newUrl.replace(/\/$/, '\/index.html')

  return { ...request, uri: newUrl }
}
