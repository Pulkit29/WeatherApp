//
//  ContentView.swift
//  WeatherAppAssignment
//
//  Created by Pulkit Arora on 15/12/24.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject private var viewModel = HomeViewModel.getInstance()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack(alignment: .center, spacing: 8.0) {
                    if viewModel.state == .noCity {
                        noCityView()
                    } else if viewModel.state == .loading {
                        loaderView()
                    }
                    else if viewModel.state == .detail {
                        VStack(alignment: .center, spacing: 8.0) {
                            Spacer()
                            detailView()
                                .frame(height: geometry.size.height * 0.4)
                            detailViewCard()
                                .frame(width: geometry.size.width * 0.7)
                                .frame(height: geometry.size.height * 0.15)
                            Spacer()
                            
                        }
                    } else if viewModel.state == .typeAheadSearch {
                        
                        searchCard()
                            .frame(width: geometry.size.width * 0.9)
                            .frame(height: geometry.size.height * 0.20)
                            .onTapGesture {
                                viewModel.saveSelectedCity(viewModel.selectedCity)
                                Task {
                                    await viewModel.setState(.detail)
                                }
                            }
                    } else {
                        VStack {
                            
                        }
                    }
                    
                    Spacer()
                }
                .background(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .searchable(text: $viewModel.selectedCity, prompt: "Search Location")
        }
    }
    
    @ViewBuilder
    private func loaderView() -> some View {
        VStack(alignment: .center) {
            ProgressView()
                .controlSize(.large)
        }
    }
    
    @ViewBuilder
    private func noCityView() -> some View {
        VStack(alignment: .center, spacing: 8.0) {
            
            Text(viewModel.noCityText())
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(viewModel.noCitySubText())
                .font(.body)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func detailView() -> some View {
        VStack(alignment: .center, spacing: 8.0) {
            AsyncImage(url: URL(string: viewModel.getWeatherIcon())) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
                    .controlSize(.large)
            }
            .frame(width: 100, height: 100)
            
            HStack(alignment: .top) {
                Text(viewModel.getCityName())
                    .font(.body)
                    .fontWeight(.bold)
                Image("nav")
                    .resizable()
                    .frame(width: 10)
                    .frame(height: 10)
                    .offset(y: 4)
            }
            HStack(alignment: .top) {
                let val = "\(viewModel.getTemperature())"
                Text(val)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("°")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func detailViewCard() -> some View {
        ZStack(alignment: .center) {
            Color.gray.opacity(0.2)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                
            HStack(alignment: .center, spacing: 10.0) {
                VStack(alignment: .center, spacing: 8.0) {
                    Text("Humidity")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(viewModel.getHumidity())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                }
                Spacer()
                VStack(alignment: .center, spacing: 8.0) {
                    Text("UV")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(viewModel.getUV())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                }
                Spacer()
                VStack(alignment: .center, spacing: 8.0) {
                    Text("Feels like")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(viewModel.getFeelsLike())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    
    @ViewBuilder
    private func searchCard() -> some View {
        ZStack(alignment: .center) {
            Color.gray.opacity(0.2)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            
            HStack(alignment: .center, spacing: 8.0) {
                VStack(alignment: .center, spacing: 6.0) {
                    HStack(alignment: .top) {
                        Text(viewModel.getCityName())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Image("nav")
                            .resizable()
                            .frame(width: 10)
                            .frame(height: 10)
                            .offset(y: 4)
                    }
                    
                    HStack(alignment: .top) {
                        Text(viewModel.getTemperature())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("°")
                    }
                }
                Spacer()
                AsyncImage(url: URL(string: viewModel.getWeatherIcon())) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                        .controlSize(.large)
                }
                .frame(width: 100, height: 100)
                
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

#Preview {
    HomeView()
}
