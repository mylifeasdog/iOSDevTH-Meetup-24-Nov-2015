//: Result: With the power of Swift enum

import UIKit

typealias DataCallback = Result<ErrorType, NSData> -> ()
typealias UserCallback = Result<ErrorType, User> -> ()
typealias ImageCallback = Result<ErrorType, UIImage> -> ()

struct User { let avatarURL: NSURL }

enum UserErrorDomain: ErrorType
{
  case UserNotFound
}

enum DownloadErrorDomain: ErrorType
{
  case ServerTimeout
}

func downloadFile(URL: NSURL, callback: DataCallback)
{
  if let data = NSData(contentsOfURL: URL)
  {
    callback(.Success(data))
  }
  else
  {
    callback(.Failure(DownloadErrorDomain.ServerTimeout))
  }
}

func requestUserInfo(userID: String, callback: UserCallback)
{
  let imagePath = NSBundle.mainBundle().pathForResource(userID.lowercaseString, ofType: "jpeg")
  let imageURLPath = imagePath.map() { NSURL(fileURLWithPath: $0) }
  let user = imageURLPath.map() { User(avatarURL: $0) }
  
  if let user = user
  {
    callback(.Success(user))
  }
  else
  {
    callback(.Failure(UserErrorDomain.UserNotFound))
  }
}

func downloadImage(URL: NSURL, callback: ImageCallback)
{
  downloadFile(URL)
    {
      result in
      
      switch result
      {
      case .Failure(let error): callback(.Failure(error))
      case .Success(let data): callback(.Success(UIImage(data: data)!))
      }
  }
}

func loadAvatar(userID: String, callback: ImageCallback)
{
  requestUserInfo(userID)
    {
      requestUserInfoResult in
      
      switch requestUserInfoResult
      {
      case .Failure(let error):
        callback(.Failure(error))
      case .Success(let user):
        downloadImage(user.avatarURL)
          {
            downloadImageResult in
            
            switch downloadImageResult
            {
            case .Failure(let error):
              callback(.Failure(error))
            case .Success(let image):
              callback(.Success(image))
            }
        }
      }
  }
}

// Fail
loadAvatar("Grumpy_Cat")
  {
    result in
    
    switch result
    {
    case .Failure(let error):
      do
      {
        throw error
      }
      catch DownloadErrorDomain.ServerTimeout
      {
        print("ServerTimeout")
      }
      catch UserErrorDomain.UserNotFound
      {
        print("UserNotFound")
      }
      catch _
      {
        print("There is an error.")
      }
    case .Success(let image):
      image
    }
}

// Success
loadAvatar("Nyan_Cat")
  {
    result in
    
    switch result
    {
    case .Failure(let error):
      do
      {
        throw error
      }
      catch DownloadErrorDomain.ServerTimeout
      {
        print("ServerTimeout")
      }
      catch UserErrorDomain.UserNotFound
      {
        print("UserNotFound")
      }
      catch _
      {
        print("There is an error.")
      }
    case .Success(let image):
      image
    }
}

//: [Future](@next)

