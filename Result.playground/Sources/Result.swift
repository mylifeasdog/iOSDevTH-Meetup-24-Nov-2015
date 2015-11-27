import Foundation

public enum Result<Error, Value>
{
    case Failure(Error)
    case Success(Value)
}