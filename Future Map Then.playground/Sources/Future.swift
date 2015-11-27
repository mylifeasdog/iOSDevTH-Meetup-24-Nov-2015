import Foundation

public struct Future<Error, Value>
{
    public typealias ResultType = Result<Error, Value>
    public typealias Callback = ResultType -> ()
    public typealias AsyncOperation = Callback -> ()
    
    private let operation: AsyncOperation
    
    public init(operation: AsyncOperation)
    {
        self.operation = operation
    }
    
    public func start(callback: Callback)
    {
        operation() { callback($0) }
    }
}

extension Future
{
    public func map<T>(f: Value -> T) -> Future<Error, T>
    {
        return Future<Error, T>()
        {
            callback in
                
            self.start()
            {
                result in
                
                switch result
                {
                    case .Success(let value): callback(Result.Success(f(value)))
                    case .Failure(let error): callback(Result.Failure(error))
                }
            }
        }
    }
    
    public func then<T>(f: Value -> Future<Error, T>) -> Future<Error, T>
    {
        return Future<Error, T>()
        {
            callback in
                
            self.start()
            {
                result in
                    
                switch result
                {
                    case .Success(let value): f(value).start(callback)
                    case .Failure(let error): callback(Result.Failure(error))
                }
            }
        }
    }
}