//: Future with Map and Then

import UIKit

struct User { let avatarURL: NSURL }

enum UserErrorDomain: ErrorType
{
  case UserNotFound
}

enum DownloadErrorDomain: ErrorType
{
  case ServerTimeout
}

func downloadFile(URL: NSURL) -> Future<ErrorType, NSData>
{
  return Future()
    {
      callback in
      
      if let data = NSData(contentsOfURL: URL)
      {
        callback(.Success(data))
      }
      else
      {
        callback(.Failure(DownloadErrorDomain.ServerTimeout))
      }
  }
}

func requestUserInfo(userID: String) -> Future<ErrorType, User>
{
  return Future()
    {
      callback in
      
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
}

func downloadImage(URL: NSURL) -> Future<ErrorType, UIImage>
{
  return downloadFile(URL).map() { UIImage(data: $0)! }
}

func loadAvatar(userID: String) -> Future<ErrorType, UIImage>
{
  return requestUserInfo(userID).map() { $0.avatarURL }.then(downloadImage)
}

// Fail
loadAvatar("Grumpy_Cat").start
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
loadAvatar("Nyan_Cat").start
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
