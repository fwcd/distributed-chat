//
//  StringUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

extension String {
    public func pluralized(with n: Int) -> String {
        n == 1 ? self : "\(self)s"
    }
}
