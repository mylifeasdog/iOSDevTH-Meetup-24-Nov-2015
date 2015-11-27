//: Playground - noun: a place where people can play

import UIKit

typealias DataCallback = (ErrorType?, NSData?) -> ()
typealias UserCallback = (ErrorType?, User?) -> ()
typealias ImageCallback = (ErrorType?, UIImage?) -> ()

struct User { let avatarURL: NSURL }

enum UserErrorDomain: ErrorType
{
    case UserNotFound
}

enum DownloadErrorDomain: ErrorType
{
    case ServerTimeout
}

enum WeirdErrorDomain: ErrorType
{
    case ThisIsWeird
}

func downloadFile(URL: NSURL, callback: DataCallback)
{
    if let data = NSData(contentsOfURL: URL)
    {
        callback(nil, data)
    }
    else
    {
        callback(DownloadErrorDomain.ServerTimeout, nil)
    }
}

func requestUserInfo(userID: String, callback: UserCallback)
{
    let imagePath = NSBundle.mainBundle().pathForResource(userID.lowercaseString, ofType: "jpeg")
    let imageURLPath = imagePath.map() { NSURL(fileURLWithPath: $0) }
    let user = imageURLPath.map() { User(avatarURL: $0) }
    
    if let user = user
    {
        callback(nil, user)
    }
    else
    {
        callback(UserErrorDomain.UserNotFound, nil)
    }
}

func downloadImage(URL: NSURL, callback: ImageCallback)
{
    downloadFile(URL)
    {
        (error, data) in
        
        if let error = error
        {
            callback(error, nil)
        }
        else if let data = data
        {
            callback(nil, UIImage(data: data)!)
        }
        else
        {
            callback(WeirdErrorDomain.ThisIsWeird, nil)
        }
    }
}

func loadAvatar(userID: String, callback: ImageCallback)
{
    requestUserInfo(userID)
    {
        (userInfoError, user) in
        
        if let userInfoError = userInfoError
        {
            callback(userInfoError, nil)
        }
        else if let user = user
        {
            downloadImage(user.avatarURL)
            {
                (downloadImageError, image) in
                
                if let downloadImageError = downloadImageError
                {
                    callback(downloadImageError, nil)
                }
                else if let image = image
                {
                    callback(nil, image)
                }
                else
                {
                    callback(WeirdErrorDomain.ThisIsWeird, nil)
                }
            }
        }
        else
        {
            callback(WeirdErrorDomain.ThisIsWeird, nil)
        }
    }
}

// Fail
loadAvatar("Grumpy_Cat")
{
    if let error = $0
    {
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
    }
    else if let image = $1
    {
        image
    }
    else
    {
        // ;
    }
}

// Success
loadAvatar("Nyan_Cat")
{
    if let error = $0
    {
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
    }
    else if let image = $1
    {
        image
    }
    else
    {
        // ;
    }
}
