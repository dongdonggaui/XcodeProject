//
//  swift
//  xcp
//
//  Created by kingkong999yhirose on 2016/09/20.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

// MARK: - Name space
public enum /* prefix */ PBX { }

extension /* prefix */ PBX {
    open class Project: Object {
        open var developmentRegion: String  { return self.extractString(for: "developmentRegion") }
        open var hasScannedForEncodings: Bool { return self.extractBool(for: "hasScannedForEncodings") }
        open var knownRegions: [String] { return self.extractStrings(for: "knownRegions") }
        open var targets: [PBX.NativeTarget] { return self.extractObjects(for: "targets") }
        open var mainGroup: PBX.Group { return self.extractObject(for: "mainGroup") }
        open var buildConfigurationList: XC.ConfigurationList { return self.extractObject(for: "buildConfigurationList") }
        open var attributes: PBXRawMapType { return self.extractPair(for: "attributes") }
    }
    
    open class ContainerItemProxy: ContainerItem {
        
    }
    
    open class BuildFile: ProjectItem {
        // NOTE: if self is swift package manager dependency source file, fileRef is not exists
        open var fileRef: PBX.Reference? { self.extractObjectIfExists(for: "fileRef") }
        open var productRef: XC.SwiftPackageProductDependency? { self.extractObjectIfExists(for: "productRef") }
    }
    
    open class CopyFilesBuildPhase: PBX.BuildPhase {
        open var name: String? { return self.extractStringIfExists(for: "name") }
    }
    
    open class FrameworksBuildPhase: PBX.BuildPhase {
        
    }
    
    open class HeadersBuildPhase: PBX.BuildPhase {
        
    }
    
    open class ResourcesBuildPhase: PBX.BuildPhase {
        override open var objectDictionary: PBXRawMapType {
            return [
                "isa": isa.rawValue,
                "buildActionMask": Int32.max,
                "files": files.map { $0.id },
                "runOnlyForDeploymentPostprocessing": 0
            ]
        }
    }
    
    open class ShellScriptBuildPhase: PBX.BuildPhase {
        open var name: String? { return self.extractStringIfExists(for: "name") }
        open var shellScript: String { return self.extractString(for: "shellScript") }
    }
    
    open class SourcesBuildPhase: PBX.BuildPhase {
        override open var objectDictionary: PBXRawMapType {
             return [
                "isa": isa.rawValue,
                "buildActionMask": Int32.max,
                "files": files.map { $0.id },
                "runOnlyForDeploymentPostprocessing": 0
            ]
        }
    }
    
    open class BuildStyle: ProjectItem {
        
    }
    
    open class AggregateTarget: Target {
        
    }
    
    open class NativeTarget: Target {
        open var packageProductDependencies: [XC.SwiftPackageProductDependency]? { extractObjects(for: "packageProductDependencies") }
    }
    
    open class TargetDependency: ProjectItem {
        
    }
    
    open class Reference: ContainerItem {
        open var name: String? { return self.extractStringIfExists(for: "name") }
        open var path: String? { return self.extractStringIfExists(for: "path") }
        open var sourceTree: SourceTreeType { return SourceTreeType(for: self.extractString(for: "sourceTree")) }
    }
    
    open class ReferenceProxy: Reference {
        // convenience accessor
        open var remoteRef: ContainerItemProxy { return self.extractObject(for: "remoteRef") }
    }
    
    open class FileReference: Reference {
        // convenience accessor
        open var fullPath: PathComponent? {
            return self.generateFullPath()
        }
        
        fileprivate func generateFullPath() -> PathComponent? {
            guard let path = context.fullFilePaths[self.id] else {
                // fatalError(assertionMessage(description:
                //     "unexpected id: \(id)",
                //     "and fullFilePaths: \(context.fullFilePaths)"
                //     )
                // )
                print("unexpected id: \(id), file name: \(self.path)")
                
                return nil
            }
            return path
        }
    }
    
    open class Group: Reference {
        override open var objectDictionary: PBXRawMapType {
            var pair: PBXRawMapType = [
                "isa": isa.rawValue,
                "children": children.map { $0.id },
                "sourceTree": sourceTree.value
            ]
            if let name = name  {
                pair["name"] = name
            }
            if let path = path {
                pair["path"] = path
            }
            return pair
        }
        
        lazy var _children: [Reference] = self.extractObjects(for: "children")
        public var children: [Reference] {
            get { return _children }
            set {
                defer {
                    _children = newValue
                }
                let appendDiff = diffing(lhs: newValue, rhs: _children)
                appendDiff.forEach { difference in
                    context.objects[difference.element.id] = difference.element
                }
                let removeDiff = diffing(lhs: _children, rhs: newValue)
                removeDiff.forEach { difference in
                    context.objects[difference.element.id] = nil
                }
            }
        }
        
        open var fullPath: String = ""
        
        // convenience accessor
        open var subGroups: [Group] { return children.ofType(PBX.Group.self) }
        open var fileRefs: [PBX.FileReference] { return children.ofType(PBX.FileReference.self) }
        
        public func appendFile(name: String) {
            children.append(
                FileReferenceMakerImpl()
                    .make(context: context, fileName: name)
            )
        }

        public func appendGroup(name: String) {
            children.append(GroupMakerImpl().make(context: context, pathName: name))
        }
        
        @discardableResult public func removeFile(fileName: String) -> PBX.FileReference? {
            guard let fileRef = FileRefExtractorImpl().extract(context: context, groupPath: fullPath, fileName: fileName) else {
                fatalError("Could not find file reference for filename of \(fileName)")
            }
            
            let index = children.firstIndex { $0.id == fileRef.id }
            switch index {
            case .none:
                assertionFailure(assertionMessage(description: "Maybe should exists index"))
            case .some(let index):
                children.remove(at: index)
            }
            
            return fileRef
        }
    }
    
    open class VariantGroup: PBX.Group {
        
    }
    
}
