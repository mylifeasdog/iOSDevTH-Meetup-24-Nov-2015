//: Playground - noun: a place where people can play

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
        if let data = NSData(contentsOfURL: URL)
        {
            $0(.Success(data))
        }
        else
        {
            $0(.Failure(DownloadErrorDomain.ServerTimeout))
        }
    }
}

func requestUserInfo(userID: String) -> Future<ErrorType, User>
{
    return Future()
    {
        let imagePath = NSBundle.mainBundle().pathForResource(userID.lowercaseString, ofType: "jpeg")
        let imageURLPath = imagePath.map() { NSURL(fileURLWithPath: $0) }
        let user = imageURLPath.map() { User(avatarURL: $0) }
        
        if let user = user
        {
            $0(.Success(user))
        }
        else
        {
            $0(.Failure(UserErrorDomain.UserNotFound))
        }
    }
}

func downloadImage(URL: NSURL) -> Future<ErrorType, UIImage>
{
    return Future()
    {
        callback in
        
        downloadFile(URL).start()
        {
            result in
            
            switch result
            {
                case .Failure(let error): callback(.Failure(error))
                case .Success(let data): callback(.Success(UIImage(data: data)!))
            }
        }
    }
}

func loadAvatar(userID: String) -> Future<ErrorType, UIImage>
{
    return Future()
    {
        callback in
            
        requestUserInfo(userID).start()
        {
            result in
            
            switch result
            {
                case .Failure(let error): callback(.Failure(error))
                case .Success(let user): downloadImage(user.avatarURL).start(callback)
            }
        }
    }
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
