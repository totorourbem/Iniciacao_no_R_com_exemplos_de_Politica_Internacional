#Comandos Etapa 12 - Teste Qui quadrado#

library(readxl)

venezuela<-read_xls("C:/Users/Paulo/Documents/Documents/CursoR_Apolo/Bases de dados/Entrada_Venezuela_CN.xls")

venezuela$Ideologia <- factor(venezuela$Ideologia,
                    levels = c(0,1),
                    labels = c("Direita", "Esquerda"))

venezuela$Coaliz�o <- factor(venezuela$Coaliz�o,
                              levels = c(0,1),
                              labels = c("Oposi��o", "Governo"))

venezuela$Voto <- factor(venezuela$Voto,
                             levels = c(0,1),
                             labels = c("N�o", "Sim"))


attach(venezuela)

t1 = table(Voto,Ideologia)
barplot(t1, beside=TRUE, legend=TRUE, ylim=c(0,200),main="Gr�fico 1. Aprova��o Entrada da Venezuela no MERCOSUL por Ideologia")


chisq.test(t1)


t2 = table(Voto,Coaliz�o)
barplot(t2, beside=TRUE, legend=TRUE, ylim=c(0,300) , args.legend = list(bty = "n", x = "top", cex=2.0, ncol = 2), main="Gr�fico 2. Aprova��o Entrada da Venezuela no MERCOSUL por Coaliz�o")

chisq.test(t2)





