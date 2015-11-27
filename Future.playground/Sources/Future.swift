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
