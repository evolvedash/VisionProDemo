//
//  ImmersiveView.swift
//  WallArt
//
//  Created by macmini on 13/10/2023.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @Environment(ViewModel.self) private var viewModel
    
    private static let planeX: Float = 3.75
    private static let planeZ: Float = 2.625
    
    @State private var inputText = ""
    @State public var showTextField = false

    
    @State var characterEntity: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0.70, -0.35, -1]
        let radians = -50 * Float.pi/180
        ImmersiveView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
        return headAnchor
    }()
    
    @State var planeEntity: Entity = {
        let wallAnchor = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2<Float>(0.6, 0.6)))
        let planeMesh = MeshResource.generatePlane(width: Self.planeX, depth: Self.planeZ, cornerRadius: 0.1)
        let material = SimpleMaterial(color: .green, isMetallic: false)
//        let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [ImmersiveView.loadImageMaterial(imageUrl: "think_different")])
        planeEntity.name = "canvas"
        wallAnchor.addChild(planeEntity)
        return wallAnchor
    }()
    
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            do { let immersiveEntitiy = try await Entity(named: "Immersive", in: realityKitContentBundle)
                characterEntity.addChild(immersiveEntitiy)
                content.add(characterEntity)
                content.add(planeEntity)
                
                
                // attachments
                guard let attachmentEntity = attachments.entity(for: "red_e") else { return }
                attachmentEntity.position = SIMD3<Float>(0, 0.62, 0)
                let radians = 30 * Float.pi / 180
                ImmersiveView.rotateEntityAroundYAxis(entity: attachmentEntity, angle: radians)
                characterEntity.addChild(attachmentEntity)
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } attachments: {
            Attachment(id: "h1") {
                VStack {
                    Text(inputText)
                        .frame(maxWidth: 600, alignment: .leading)
                        .font(.extraLargeTitle2)
                        .fontWeight(.regular)
                        .padding(40)
                        .glassBackgroundEffect()
                }.tag("attachment")
                    .opacity(showTextField ? 0 : 1)
            }
        } .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { _ in
            viewModel.flowState = .into
        })
        .onChange(of: viewModel.flowState) { oldValue, newValue in
            switch newValue {
            case .idle:
                break
            case .into:
                playIntroSequence()
            case .projectileFlying:
                break
            case .updateWallArt:
                break
            }
        }
    }
    
    static func rotateEntityAroundYAxis(entity: Entity, angle: Float)
    {
        var currentTransform = entity.transform
        let rotation = simd_quatf(angle: angle, axis:[0, 1, 0])
        currentTransform.rotation = rotation  * currentTransform.rotation
        entity.transform = currentTransform
    }
    
    static func loadImageMaterial(imageUrl: String) -> SimpleMaterial {
        do {
            let texture = try TextureResource.load(named: imageUrl)
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            return material
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    func playIntroSequence() {
        Task {
            //show dialogue box
            if !showTextField {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTextField.toggle()
                }
            }
        }
    }

}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
