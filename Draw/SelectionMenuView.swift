//
//  SelectionMenuView.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 06/08/23.
//
import Foundation
import UIKit

class SelectionMenuView: UIView {
    
    static let selectionMenu = SelectionMenuView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
    
    private var collectionView: UICollectionView!
    var menuOptions: [String] = []
    var standardOptions: [String] = ["Copia", "Taglia", "Duplica", "Stile", "Elimina"]
    var pasteOptions: [String] = ["Incolla"]
    private var isPresented = true
    
    var currentPosition : CGPoint = .zero
    
    public var copy : [Stroke: CGAffineTransform] = [:]
    
    weak var delegate: SelectionMenuViewDelegate?

    override private init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        if copy.count == 0 {
            setMenuOptions(options: standardOptions)
        }
        else {
            setMenuOptions(options: pasteOptions)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Configura la UICollectionView e il layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        // Registra la cella personalizzata per gli elementi del menu
        collectionView.register(MenuOptionCell.self, forCellWithReuseIdentifier: "MenuOptionCell")
        
        collectionView.backgroundColor = .clear // Sfondo trasparente
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Margine sinistro e destro

        addSubview(collectionView)
    }

    func setMenuOptions(options: [String]) {
        menuOptions = options
        collectionView.reloadData()
    }
    
    func resetMenu(){
        isPresented = true
        UIView.animate(withDuration: 0.2) {
            
            SelectionMenuView.selectionMenu.transform = SelectionMenuView.selectionMenu.transform.concatenating(CGAffineTransform(scaleX: 0, y: 0))
        }
        SelectionMenuView.selectionMenu.isHidden = true
        
    }
    
    func useMenu(atPoint: CGPoint){
        if isPresented {
            SelectionMenuView.selectionMenu.isHidden = false
                let translate = CGAffineTransform(translationX: atPoint.x, y: atPoint.y)
                let scale = CGAffineTransform(scaleX: 1, y: 1)
                
            let combined = translate.concatenating(scale)
            
            UIView.animate(withDuration: 0.2) {
                SelectionMenuView.selectionMenu.transform = combined
            }
            
            currentPosition = atPoint
            isPresented = false
        }
        else{
            currentPosition = .zero
            resetMenu()
        }
    }
}

extension SelectionMenuView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuOptionCell", for: indexPath) as! MenuOptionCell
        cell.optionText = menuOptions[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = menuOptions[indexPath.item]
        //print("Opzione selezionata: \(selectedItem)")
        
        if selectedItem == "Elimina"{
            delegate?.delete()
        }
        
        if selectedItem == "Copia"{
            delegate?.copy()
        }
        
        if selectedItem == "Incolla"{
            _ = delegate?.paste()
        }
        
        if selectedItem == "Taglia"{
            delegate?.cut()
        }
        
        if selectedItem == "Duplica"{
            delegate?.duplicate()
        }
        
        if selectedItem == "Stile"{
            delegate?.style()
        }
        
    }
}

class MenuOptionCell: UICollectionViewCell {
    private let titleLabel: UILabel = UILabel()

    var optionText: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Configura l'etichetta del titolo
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white // Colore del testo
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold) // Font del testo
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Aggiungi i layout constraints per centrare l'etichetta nel contenitore della cella
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // Applica uno stile grafico alla cella
        layer.cornerRadius = 8 // Bordi arrotondati
        layer.borderWidth = 1 // Spessore del bordo
        layer.borderColor = UIColor.black.cgColor // Colore del bordo
        layer.masksToBounds = true // Per mascherare i contenuti oltre i bordi arrotondati
        backgroundColor = UIColor.gray // Colore di sfondo della cella
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Aggiorna il layout dell'etichetta del titolo, se necessario
    }
    
//    override var isSelected: Bool {
//        didSet {
//            // Esegui un'animazione di ingrandimento quando la cella viene selezionata
//            let scale: CGFloat = isSelected ? 1.2 : 1.0
//            UIView.animate(withDuration: 0.2) {
//                self.transform = CGAffineTransform(scaleX: scale, y: scale)
//            }
//        }
//    }
}

protocol SelectionMenuViewDelegate: AnyObject{
    func delete()
    func copy()
    func paste() -> [Stroke]
    func cut()
    func duplicate()
    func style()
}

class SMVDelegate: SelectionMenuViewDelegate{
    var canvasView: CanvasView
    
    init(_ canvasView: CanvasView){
        self.canvasView = canvasView
    }
    
    func delete(){
        if let lasso = canvasView.tool as? Lasso{
            lasso.deleteStroke(removeFrom: canvasView.drawing)
        }
        canvasView.drawing.removeLassoStrokes()
        SelectionMenuView.selectionMenu.resetMenu()
        canvasView.setNeedsDisplay()
    }
    
    func copy(){
        SelectionMenuView.selectionMenu.copy = [:]
        if let lasso = canvasView.tool as? Lasso{
            let lassoStrokeCenter = calculateCenterOfStroke(stroke: lasso.stroke)
            for stroke in lasso.selectedStrokes{
                let strokeCenter = calculateCenterOfStroke(stroke: stroke)
                
                let translation = calculateTranslationBetweenPoints(from: lassoStrokeCenter, to: strokeCenter)
                SelectionMenuView.selectionMenu.copy[stroke] = translation
            }
            lasso.selectedStrokes = []
            
        }
        SelectionMenuView.selectionMenu.setMenuOptions(options: SelectionMenuView.selectionMenu.pasteOptions)
        canvasView.drawing.removeLassoStrokes()
        SelectionMenuView.selectionMenu.resetMenu()
        canvasView.setNeedsDisplay()
    }
    
    func paste() -> [Stroke]{
        var newStrokes : [Stroke] = []
        
        for copiedStroke in SelectionMenuView.selectionMenu.copy.keys{
            let stroke = copiedStroke.copy()
            
            let center = calculateCenterOfStroke(stroke: stroke)
            
            var transform = calculateTranslationBetweenPoints(from: center, to: SelectionMenuView.selectionMenu.currentPosition)
            if let shiftTranslation = SelectionMenuView.selectionMenu.copy[copiedStroke]{
                transform = transform.concatenating(shiftTranslation)
            }
            
            stroke.apply(transform)
            canvasView.drawing.append(stroke)
            newStrokes.append(stroke)
        }
        canvasView.drawing.removeLassoStrokes()
        SelectionMenuView.selectionMenu.resetMenu()
        canvasView.setNeedsDisplay()
        
        return newStrokes
    }
    
    func cut(){
        copy()
        delete()
    }
    
    func duplicate() {
        copy()
        shiftForDuplication()
        let duplicateStrokes = paste()
        
        if let lasso = canvasView.tool as? Lasso{
            lasso.selectedStrokes = duplicateStrokes
            canvasView.drawing.append(lasso.stroke)
        }
        SelectionMenuView.selectionMenu.resetMenu()
        SelectionMenuView.selectionMenu.setMenuOptions(options: SelectionMenuView.selectionMenu.standardOptions)
        canvasView.setNeedsDisplay()
    }
    
    func shiftForDuplication(){
        if let lasso = canvasView.tool as? Lasso{
            SelectionMenuView.selectionMenu.currentPosition = calculateCenterOfStroke(stroke: lasso.stroke)
            SelectionMenuView.selectionMenu.currentPosition = CGPoint(x: SelectionMenuView.selectionMenu.currentPosition.x + 10, y: SelectionMenuView.selectionMenu.currentPosition.y + 10)
            lasso.stroke.apply(CGAffineTransform(translationX: 10, y: 10))
        }
    }
    
    func style() {
        if let lasso = canvasView.tool as? Lasso{
            for stroke in lasso.selectedStrokes{
                stroke.color = .red
            }
        }
        canvasView.drawing.removeLassoStrokes()
        SelectionMenuView.selectionMenu.resetMenu()
        canvasView.setNeedsDisplay()
    }
}
