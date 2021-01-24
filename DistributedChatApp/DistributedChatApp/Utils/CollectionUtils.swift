//
//  CollectionUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

extension Sequence where Element: Hashable {
    /// Filters only distinct elements.
    var distinct: [Element] {
        var found = Set<Element>()
        var xs = [Element]()
        for x in self {
            let (inserted, _) = found.insert(x)
            if inserted {
                xs.append(x)
            }
        }
        return xs
    }
}
