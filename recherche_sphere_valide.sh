#!/bin/bash
pMEFPP=$3
pPrefixe=$1
pMaillageBasePrefixe=$2

echo "MEFPP commande: ${MEFPP}"
echo "Préfixe: ${pPrefixe}"
echo "Maillages: ${pMaillageBasePrefixe}"

lRayon=2661
lMailles=(16 32 64 128 256)
lNbEssais=50
# Varie le rayon à chaque itération; et découpe chaque maillage
for (( i=0; $i < $lNbEssais; i++ )); do
	lInvalide=0
	sed -i "s/scalaire r0 .*/scalaire r0 0.0${lRayon}/" "${pPrefixe}.champs"
	for (( i=0; $i < ${#lMailles[@]}; i++ )); do
		echo "Maillage #$i: ${pMaillageBasePrefixe}${lMailles[$i]}.mail"
		ln -sf "${pMaillageBasePrefixe}${lMailles[$i]}.mail" "${pPrefixe}.mail"
		#ln -sf "${pMaillageBasePrefixe}${lMailles[$i]}.enti" "${pPrefixe}.enti"
		{ $pMEFPP $pPrefixe & echo "$!" > .mefpp.pid; } |& tee .mefppout &
		# Termine le calcul mefpp dès qu'une intersection invalide est détectée
		# tant que le process mefpp roule
		# vérifie la sortie écran
		# et tue le process dès qu'une intersection est détectée
		child="$( cat .mefpp.pid )"
		while (ps -p "$child" &> /dev/null) 
		do
			if grep -q "intersection" .mefppout; then
				kill -9 "$child"
				echo "Termine test invalide $lRayon:${lMailles[$i]}"
				break
			fi
			sleep 5; # dort X secondes entre chaque vérification
	       	done
		# incrémente le compteur de cas invalides
		if grep -q "intersection" .mefppout; then lInvalide=$(( $lInvalide + 1 )); fi
		#wait "$child"
	done
	# Vérifie la sortie écran et quitte si aucune instersection invalide détectée
	if [ lInvalide = "0" ]; then
		echo "Sphere valide r=${lRayon}"
		exit 0
	fi
	# Sinon on recommence avec un nouveau rayon
	lRayon=$(( $lRayon + 1 ))
done

