#' Main CogMedia Code
#' @param source Long name for source, such as 'New York Times'
#' @param dt1 'YYYY-MM-DD' format for date 1 of interval
#' @param dt2 'YYYY-MM-DD' format for date 2 of interval
#' @param search Keyword search inside the database
#' @param n_stories Number of stories; may be limited by API
#' @param peruse A formatted text prompt is presented to read the news inside R
#' @param api_key API key supplied by the CogMedia project
#' @return A data frame with stories and their properties for NLP or other applications

.packageName <- 'cogmedia'

cogmedia_data = function(source='all',dt1=yesterday(),dt2=tomorrow(),search='',
                         n_stories=10,api_key,peruse=FALSE) {
  url = 'https://co-mind.org/cogmedia/api-php-base?'
  url = paste(url,'f=data&source=',urltools::url_encode(source),
              '&api_key=',urltools::url_encode(api_key),
              '&dt1=',urltools::url_encode(dt1),
              '&dt2=',urltools::url_encode(dt2),
              '&search=',urltools::url_encode(search),
              '&n_stories=',urltools::url_encode(n_stories),sep='')
  stories = jsonlite::fromJSON(url)
  if (!is.null(stories$error) | length(stories)==0) {
    return(stories)
  } else {
    stories$title = trimws(urltools::url_decode(stories$title))
    stories$description = urltools::url_decode(stories$description)
    stories$social_score = as.numeric(stories$social_score)
    stories$alexa_rank = as.numeric(stories$alexa_rank)
    if (!peruse) {
      return(stories)
    } else {
      for (i in 1:nrow(stories)) {
        cat(as.character(i)%+%'. '%+%bold(stories[i,]$title)%+%' ('%+%stories[i,]$source%+%', '%+%stories[i,]$story_date%+%')\n')
      }
      command = ''
      while (command!='q') {
        command = readline('goto X, describe X, or type q to quit perusing: ')
        components = unlist(strsplit(command, ' '))
        if (components[1]=='describe') {
          i = as.numeric(components[2])
          cat(as.character(i)%+%'. '%+%bold(stories[i,]$title)%+%' ('%+%stories[i,]$source%+%', '%+%stories[i,]$story_date%+%')\n')
          cat(stories[i,]$description%+%'\n\n')
        } else if (components[1]=='goto') {
          browseURL(stories[as.numeric(components[2]),]$url)
        }
      }
      return(stories)
    }    
  }
}






