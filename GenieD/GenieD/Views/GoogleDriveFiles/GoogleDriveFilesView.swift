//
//  GoogleDriveFilesView.swift
//  GenieD
//
//  Created by OK on 21.04.2023.
//

import SwiftUI
import URLImage

struct GoogleDriveFilesView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var googleDriveManager: GoogleDriveManager
    @StateObject var viewModel = GoogleDriveFilesViewModel()
    private let onDone: (([Data])->Void)?
    
    init(onDone: @escaping ([Data])-> Void) {
        self.onDone = onDone
    }
    
    var body: some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar()
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.files.indices, id: \.self) { index in
                            fileInfoView(index: index)
                        }
                    }
                }
            }
            if viewModel.isLoading {
                LoadingView()
                    .ignoresSafeArea()
            }
        }
        .foregroundColor(CustomColor.blackText)
    }
    
    private func topBar() -> some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    onTabbarButtonAction()
                }) {
                    Text(viewModel.selectedIndexes.isEmpty ? "Cancel" : "Open")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 20.scaled)
            }
            .frame(maxHeight: .infinity)
            CustomColor.graySeparator
                .frame(height: 1)
        }
        .frame(height: 60.scaled)
    }
    
    private func fileInfoView(index: Int) -> some View {
        let item = viewModel.files[index]
        let isSelected = viewModel.selectedIndexes.contains(index)
        
        return ZStack(alignment: .bottom) {
            isSelected ? CustomColor.graySeparator : Color.clear
            HStack(spacing: 0) {
               HSpacer(20.scaled)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame( width: 25.scaled, height: 25.scaled)
                       .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame( width: 25.scaled, height: 25.scaled)
                       .foregroundColor(CustomColor.textGrayLight)
                }
                
               HSpacer(20.scaled)
               if let imageLink = URL(string: item.thumbnailLink ?? "") {
                   URLImage(url: imageLink) { image in
                       image
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame( width: 50.scaled, height: 50.scaled)
                   }
               } else {
                   Rectangle()
                       .strokeBorder(CustomColor.graySeparator)
                       .frame(width: 50.scaled, height: 50.scaled)
               }
               HSpacer(10.scaled)
               VStack(alignment: .leading, spacing: 4.scaled) {
                   Text(item.name)
                       .font(.system(size: 14, weight: .semibold))
                       .lineLimit(1)
                   Text("\(item.modifiedTime?.formatedString() ?? "") - \(item.formatedFileSize)")
                       .font(.system(size: 12, weight: .medium))
                       .foregroundColor(CustomColor.textGray)
               }
               Spacer()
               HSpacer(10.scaled)
            }
            CustomColor.graySeparator
                .frame(height: 1)
        }
        .frame(height: 60.scaled)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                viewModel.onTapFileAtIndex(index)
            }
        }
    }
    
    private func onTabbarButtonAction() {
        guard !viewModel.selectedIndexes.isEmpty else {
            dissmiss()
            return
        }
        
        viewModel.loadData { result in
            if let result = result, !result.isEmpty {
                onDone?(result)
            }
            dissmiss()
        }
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
