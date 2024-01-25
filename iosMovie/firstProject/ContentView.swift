
import SwiftUI
import Foundation

struct ContentView: View {
    @ObservedObject var viewModel = MoviesViewModel()
    @Namespace var namespace
    @State var showingDetail = false
    @State var movieSelected: MovieItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                
                if viewModel.isLoading {
                    ProgressView("Loading movies...").onAppear {
                        viewModel.fetchMovies()
                    }
                } else if viewModel.isError {
                    VStack {
                        Text("Network Error.").padding(.bottom, 16)
                        Button("Try Again") {
                            viewModel.fetchMovies()
                        }
                    }
                } else {
                    List(viewModel.movies ?? []) { movie in
                        HStack {
                            VStack {
                                AsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movie.poster_path)) { phase in
                                    switch phase {
                                    case .empty: ZStack {
                                        
                                        ProgressView()
                                    }
                                    case .success: phase.image?
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 200)
                                    default: ProgressView()
                                    }
                                    
                                }.matchedGeometryEffect(id: movie.poster_path, in: namespace)
                            }
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .font(.headline)
                                Text(movie.overview)
                                    .font(.subheadline)
                            }
                        }.onTapGesture {
                            withAnimation {
                                movieSelected = movie
                                showingDetail.toggle()
                            }
                        }
                    }.opacity(showingDetail ? 0 : 1)
                        .navigationTitle("movies")
                        .navigationBarHidden(showingDetail)
                }
                
                if(showingDetail && movieSelected != nil) {
                    MovieDetailItem(movieSelected: movieSelected!, namespace: namespace, showingDetail: $showingDetail)
                }

            }
        }
    }
    
}


struct MovieDetailItem: View {
    var movieSelected : MovieItem
    var namespace: Namespace.ID
    @Binding var showingDetail: Bool
    @State private var isNavigationBarHidden = true
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        AsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movieSelected.poster_path)) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Image(systemName: "questionmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 450)
                                        .frame(maxWidth: .infinity)
                                    
                                    ProgressView()
                                }
                            case .success:
                                phase.image?
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 450)
                                    .frame(maxWidth: .infinity)
                            default:
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 450)
                                    .frame(maxWidth: .infinity)
                            }
                        }.matchedGeometryEffect(id: movieSelected.poster_path, in: namespace)
                    }
                    VStack(alignment: .leading) {
                        
                        Text(movieSelected.title)
                            .padding(.top, 100)
                            .font(.headline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        Text(movieSelected.overview)
                            .font(.subheadline)
                        
                    }
                }
            }
            .navigationBarTitle(movieSelected.title)
            .background(NavigationConfigurator { nc in
                nc.setNavigationBarHidden(isNavigationBarHidden, animated: true)
            })
            .navigationBarItems(leading: Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isNavigationBarHidden = false
                    showingDetail.toggle()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title).imageScale(.small)
            })
        }
        
    }
}
struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}


struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        if let cgImage = self.cgImage, let pixelData = cgImage.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        return .clear
    }
}
