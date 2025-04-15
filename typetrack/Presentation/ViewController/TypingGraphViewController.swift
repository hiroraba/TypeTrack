//
//  TypingGraphViewController.swift
//  typetrack
//
//  Created by matsuohiroki on 2025/04/15.
//
//

import AppKit
import Charts
import SwiftUI

class TypingGraphViewController: NSViewController {
    override func loadView() {
        let useCase = LoadTypingHistoryUseCaseImpl(typingHistoryRepository: TypingHistoryRepositoryImpl())
        let viewModel = TypingGraphViewModel(loadTypingHistoryUseCase: useCase)
        let adapter = TypingGraphObservableAdapter(viewModel: viewModel)

        let chartVC = NSHostingView(rootView: TypingChartView(adapter: adapter))
        self.view = chartVC
    }
}

struct TypingChartView: View {
    @ObservedObject var adapter: TypingGraphObservableAdapter
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📈 typing score")
                .font(.title2)
                .padding(.bottom)

            if adapter.records.isEmpty {
                Text("履歴がありません").foregroundColor(.gray)
            } else {
                Chart {
                    ForEach(adapter.records.indices, id: \.self) { index in
                        let record = adapter.records[index]
                        PointMark(
                            x: .value("回数", index + 1),
                            y: .value("スコア", record.score)
                        )
                        .foregroundStyle(by: .value("カテゴリ", record.category))
                        .symbol(by: .value("カテゴリ", record.category))
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartLegend(position: .bottom)
                .frame(height: 300)
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
}
